module Validation
  #
  # Custom validator class
  # Must implement: set_schema(schema), validate!(params), data
  #
  class Validator
    attr_reader :data, :errors

    def initialize
      @data = {}
      @errors = {}
      @schema = {}
    end

    def set_schema(schema)
      @schema = schema
      self
    end

    def validate!(params)
      @raw = (params || {}).transform_keys(&:to_sym)
      @schema.each do |field, rules|
        rules = Array(rules) # por si alguien pasa un solo símbolo
        value = @raw[field]

        # Ejecutamos todas las reglas para el campo
        rules.each do |rule|
          case rule
          when :required then check_required(field, value)
          when :nullable then check_nullable(field, value)
          when :int      then check_type_if_not_null(field, value, Integer)
          when :float    then check_type_if_not_null(field, value, Float)
          when :string   then check_type_if_not_null(field, value, String)
          when :boolean  then check_boolean_if_not_null(field, value)
          when :optional then next
          else
            raise ArgumentError, "Unknown rule: #{rule}"
          end
        end

        # Si no hay errores para este campo y el valor no está vacío, normalizamos y guardamos
        unless @errors[field] || value.nil? || value == ""
          @data[field] = normalize_value(value, rules)
        end
      end

      raise Errors::ValidationError.new(@errors) unless @errors.empty?
      self
    end

    private

    def check_required(field, value)
      if value.nil? || value == ""
        add_error(field, "is required")
      end
    end

    def check_nullable(field, value)
      # In Laravel, nullable means the field can be null, but if it has a value,
      # it must be valid according to other rules
      # This method just allows null values, validation happens in other rules
      return if value.nil? || value == ""
      
      # Check if value is "null" string (explicit null)
      if value.to_s.downcase == "null"
        @data[field] = nil
        return
      end
      
      # For nullable, we don't validate the type here, other rules will do that
      # We just handle the "null" string case
    end

    def check_type_if_not_null(field, value, klass)
      # Skip validation if value is null (nullable fields)
      return if value.nil? || value == ""
      
      # Check if value is "null" string (explicit null)
      if value.to_s.downcase == "null"
        return
      end
      
      # Intentar convertir el valor
      begin
        if klass == Integer
          Integer(value)
        elsif klass == Float
          Float(value)
        elsif klass == String
          value.to_s
        else
          add_error(field, "must be a #{klass}")
          return
        end
      rescue ArgumentError => e
        add_error(field, "must be a valid #{klass}")
      end
    end

    def check_boolean_if_not_null(field, value)
      # Skip validation if value is null (nullable fields)
      return if value.nil? || value == ""
      
      # Check if value is "null" string (explicit null)
      if value.to_s.downcase == "null"
        return
      end
      
      unless ["true", "false", true, false, "1", "0", 1, 0].include?(value)
        add_error(field, "must be boolean")
      end
    end

    def normalize_value(value, rules)
      return nil if value.nil? || value == ""

      if rules.include?(:int)
        begin
          Integer(value)
        rescue ArgumentError
          value # Si no se puede convertir, devolver el valor original
        end
      elsif rules.include?(:nullable)
        if value.to_s.downcase == "null"
          nil
        else
          # Try to convert to integer first
          begin
            Integer(value)
          rescue ArgumentError
            # Try to convert to float
            begin
              Float(value)
            rescue ArgumentError
              # Accept as string
              value.to_s
            end
          end
        end
      elsif rules.include?(:float)
        begin
          Float(value)
        rescue ArgumentError
          value
        end
      elsif rules.include?(:boolean)
        ["true", "1", 1, true].include?(value)
      elsif rules.include?(:string)
        value.to_s.strip
      else
        value
      end
    end

    def add_error(field, message)
      (@errors[field] ||= []) << message
    end
  end
end
