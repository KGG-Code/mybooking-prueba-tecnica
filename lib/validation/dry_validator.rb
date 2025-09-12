module Validation
  #
  # Dry-validation based validator
  # Must implement: set_schema(schema), validate!(params), data
  #
  class DryValidator
    attr_reader :data, :errors

    def initialize
      @data = {}
      @errors = {}
      @schema = nil
    end

    def set_schema(schema)
      @schema = build_dry_schema(schema)
      self
    end

    def validate!(params)
      result = @schema.call(params)
      
      if result.success?
        @data = result.to_h
        @errors = {}
      else
        @errors = result.errors.to_h
        raise Errors::ValidationError.new("Validation failed", details: @errors)
      end
      
      self
    end

    private

    def build_dry_schema(schema)
      # Convertir tu schema { rental_location_id: [:required, :int] } a dry-schema
      rules = {}
      
      schema.each do |field, field_rules|
        field_rules = Array(field_rules)
        
        # Determinar si es required u optional
        if field_rules.include?(:required)
          rules[field] = { required: true }
        else
          rules[field] = { required: false }
        end
        
        # Determinar el tipo
        if field_rules.include?(:int)
          rules[field][:type] = :integer?
        elsif field_rules.include?(:string)
          rules[field][:type] = :string?
        elsif field_rules.include?(:float)
          rules[field][:type] = :float?
        elsif field_rules.include?(:boolean)
          rules[field][:type] = :bool?
        else
          rules[field][:type] = :any?
        end
      end
      
      # Crear el schema de dry-validation
      Dry::Schema.Params do
        rules.each do |field, config|
          if config[:required]
            required(field).value(config[:type])
          else
            optional(field).value(config[:type])
          end
        end
      end
    end
  end
end