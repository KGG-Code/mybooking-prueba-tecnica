# frozen_string_literal: true

require_relative 'rules/registry'
require_relative 'rules/base_rule'
require_relative 'rules/required'
require_relative 'rules/string'
require_relative 'rules/integer'
require_relative 'rules/numeric'
require_relative 'rules/email'
require_relative 'rules/min'
require_relative 'rules/max'
require_relative 'rules/in'
require_relative 'rules/regex'
require_relative 'rules/optional_rules'
require_relative 'rules/custom_rules'

module Validation
  class Error < StandardError
    attr_reader :errors
    def initialize(errors)
      super("Validation failed")
      @errors = errors
    end
  end

  # Helpers simples
  module Helpers
    module_function

    def symbolize_keys(h)
      h.each_with_object({}) { |(k,v),acc| acc[k.to_sym] = v }
    end

    def present?(v)
      return false if v.nil?
      return !v.empty? if v.respond_to?(:empty?)
      true
    end

    def to_bool(v)
      case v
      when true, "true", "1", 1, "on", "yes" then true
      when false, "false", "0", 0, "off", "no", nil, "" then false
      else :invalid
      end
    end

    EMAIL_RE = /\A[^@\s]+@[^@\s]+\z/
  end

  # Interfaz del "contract" esperado por el Validator:
  # - contract.attributes -> Hash con params
  # - contract.rules      -> Hash campo => [reglas]
  #
  # Las reglas pueden ser:
  #   :required, :nullable, :bail, :sometimes, :string, :integer, :numeric, :boolean, :email, :array
  #   [:min, N], [:max, N], [:between, a, b], [:size, N], [:in, [...]], [:regex, /.../]
  #   [:each, [...subrules...]]   # para arrays
  #   Proc                        # regla personalizada -> ->(value, all_attrs) { true/false }
  #
  class Validator
    include Helpers

    Result = Struct.new(:success?, :validated, :errors, keyword_init: true)

    attr_reader :validated, :errors

    def initialize(contract_or_rules)
      if contract_or_rules.is_a?(Hash) && contract_or_rules.key?(:rules)
        # Es un contract con reglas
        @rules = normalize_rules(contract_or_rules[:rules] || {})
        @attrs = {}
      else
        # Es un contract normal
        @attrs = Helpers.symbolize_keys(contract_or_rules.attributes || {})
        @rules = normalize_rules(contract_or_rules.rules || {})
      end
      
      @errors = Hash.new { |h,k| h[k] = [] }
      @validated = {}
      
      # Debug básico
      STDERR.puts "🔍 VALIDATOR: #{@attrs.keys.join(', ')} (#{@attrs.size} fields) | #{@rules.keys.join(', ')} (#{@rules.size} rules)"

      # Cargar reglas por defecto
      Rules::Registry.load_rules
    end

    # No lanza excepción; devuelve Result
    def validate(data = nil)
      if data
        # Si se pasan datos, los usamos
        @attrs = Helpers.symbolize_keys(data)
        @errors = Hash.new { |h,k| h[k] = [] }
        @validated = {}
        
        STDERR.puts "🔍 VALIDATOR VALIDATING: #{@attrs.keys.join(', ')} (#{@attrs.size} fields)"
      end
      # Si no se pasan datos, usamos los que ya estaban en @attrs
      
      run
      Result.new(success?: errors.values.all?(&:empty?), validated: validated, errors: errors)
    end

    # Lanza Validation::Error si hay errores (estilo Laravel "fails()")
    def validate!(data = nil)
      if data
        # Si se pasan datos, los usamos
        @attrs = Helpers.symbolize_keys(data)
        @errors = Hash.new { |h,k| h[k] = [] }
        @validated = {}
        
        STDERR.puts "🔍 VALIDATOR VALIDATING!: #{@attrs.keys.join(', ')} (#{@attrs.size} fields)"
      end
      # Si no se pasan datos, usamos los que ya estaban en @attrs
      
      run
      raise Error, errors unless errors.values.all?(&:empty?)
      validated
    end

    private

    def run
      @rules.each do |field, rule_list|
        process_field(field, rule_list)
      end
    end

    def process_field(field, raw_rules)
      value      = @attrs[field]
      rules      = raw_rules.dup
      bail       = rules.delete(:bail)
      nullable   = rules.delete(:nullable)
      sometimes  = rules.delete(:sometimes)
      required   = rules.delete(:required)

      # sometimes => solo valida si el campo está presente (como en Laravel)
      return unless !sometimes || @attrs.key?(field)

      # required
      if required && !Helpers.present?(value)
        add_error(field, "es obligatorio")
        return if bail
      end

      # si es nulo y nullable, no seguimos validando
      if value.nil?
        return unless required # si no es required y es nil, listo
        # si required + nil ya se reportó arriba; no seguimos
        return
      end

      # Aplica reglas restantes
      coerced_value = value
      rules.each do |rule|
        break if bail && errors[field].any?

        result = apply_rule(rule, coerced_value, field)
        coerced_value = result[:value] if result[:success]
        
        unless result[:success]
          add_error(field, result[:message])
        end
      end

      @validated[field] = coerced_value if errors[field].empty?
    end

    def apply_rule(rule, value, field)
      case rule
      when Symbol
        apply_symbol_rule(rule, value, field)
      when Array
        apply_array_rule(rule, value, field)
      when Proc
        apply_proc_rule(rule, value, field)
      else
        { success: false, value: value, message: "regla inválida: #{rule.inspect}" }
      end
    end

    def apply_symbol_rule(rule, value, field)
      rule_class = Rules::Registry.get(rule)
      
      if rule_class
        result = rule_class.validate(value)
        result
      else
        { success: false, value: value, message: "regla desconocida: #{rule}" }
      end
    end

    def apply_array_rule(rule, value, field)
      name, *args = rule
      
      case name
      when :min
        rule_class = Rules::Registry.get(:min)
        rule_class ? rule_class.validate(value, value: args[0]) : apply_min_rule(value, args[0])
      when :max
        rule_class = Rules::Registry.get(:max)
        rule_class ? rule_class.validate(value, value: args[0]) : apply_max_rule(value, args[0])
      when :between
        apply_between_rule(value, args[0], args[1])
      when :size
        apply_size_rule(value, args[0])
      when :in
        rule_class = Rules::Registry.get(:in)
        rule_class ? rule_class.validate(value, values: args[0]) : apply_in_rule(value, args[0])
      when :enum
        rule_class = Rules::Registry.get(:enum)
        rule_class ? rule_class.validate(value, values: args) : apply_enum_rule(value, args)
      when :regex
        rule_class = Rules::Registry.get(:regex)
        rule_class ? rule_class.validate(value, pattern: args[0]) : apply_regex_rule(value, args[0])
      when :each
        apply_each_rule(value, args[0], field)
      else
        { success: false, value: value, message: "regla desconocida: #{name}" }
      end
    end

    def apply_min_rule(value, min)
      if value.is_a?(Numeric)
        if value >= min
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe ser ≥ #{min}" }
        end
      else
        if value.to_s.length >= min
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe tener longitud ≥ #{min}" }
        end
      end
    end

    def apply_max_rule(value, max)
      if value.is_a?(Numeric)
        if value <= max
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe ser ≤ #{max}" }
        end
      else
        if value.to_s.length <= max
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe tener longitud ≤ #{max}" }
        end
      end
    end

    def apply_between_rule(value, min, max)
      if value.is_a?(Numeric)
        if (min..max).cover?(value)
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe estar entre #{min} y #{max}" }
        end
      else
        len = value.to_s.length
        if (min..max).cover?(len)
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "longitud debe estar entre #{min} y #{max}" }
        end
      end
    end

    def apply_size_rule(value, size)
      if value.is_a?(Numeric)
        if value == size
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe ser exactamente #{size}" }
        end
      else
        if value.to_s.length == size
          { success: true, value: value, message: nil }
        else
          { success: false, value: value, message: "debe tener longitud exactamente #{size}" }
        end
      end
    end

    def apply_in_rule(value, allowed_values)
      set = allowed_values || []
      if Array(set).include?(value)
        { success: true, value: value, message: nil }
      else
        { success: false, value: value, message: "debe ser uno de: #{Array(set).join(', ')}" }
      end
    end

    def apply_enum_rule(value, allowed_values)
      set = allowed_values || []
      if Array(set).include?(value)
        { success: true, value: value, message: nil }
      else
        { success: false, value: value, message: "debe ser uno de: #{Array(set).join(', ')}" }
      end
    end

    def apply_regex_rule(value, regex)
      if regex === value.to_s
        { success: true, value: value, message: nil }
      else
        { success: false, value: value, message: "formato inválido" }
      end
    end

    def apply_each_rule(value, subrules, field)
      arr = value.is_a?(Array) ? value : Array(value)
      arr.each_with_index do |item, idx|
        item_errors = validate_value_against_rules(item, subrules, field, idx)
        item_errors.each { |msg| add_error("#{field}.#{idx}".to_sym, msg) }
      end
      { success: true, value: value, message: nil }
    end

    def apply_proc_rule(rule, value, field)
      ok, msg = rule.call(value, @attrs)
      if ok
        { success: true, value: value, message: nil }
      else
        { success: false, value: value, message: (msg || "no pasó validación") }
      end
    end

    def validate_value_against_rules(value, subrules, field, _idx)
      tmp_errors = []
      coerced = value
      subrules.each do |rule|
        result = apply_rule(rule, coerced, field)
        coerced = result[:value] if result[:success]
        
        unless result[:success]
          tmp_errors << result[:message]
        end
      end
      tmp_errors
    end

    def add_error(field, message)
      errors[field.to_sym] << message
    end

    def normalize_rules(h)
      h.each_with_object({}) do |(k,v), acc|
        acc[k.to_sym] = case v
                        when String
                          # si quisieras aceptar "required|string|email"
                          v.split("|").map { |part| part.strip.to_sym }
                        when Array
                          v
                        when Symbol
                          [v]
                        else
                          []
                        end
      end
    end
  end
end