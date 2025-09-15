# frozen_string_literal: true

module Validation
  module Rules
    # Regla para campos opcionales
    class Optional < BaseRule
      def self.validate(value, options = {})
        # Si el valor está presente, lo validamos con las reglas siguientes
        # Si no está presente, es válido
        if Helpers.present?(value)
          success_message(value)
        else
          success_message(nil)
        end
      end
    end

    # Regla para campos nullable (pueden ser nil)
    class Nullable < BaseRule
      def self.validate(value, options = {})
        # Siempre es válido, incluso si es nil
        success_message(value)
      end
    end

    # Regla para enteros (alias de integer)
    class Int < BaseRule
      def self.validate(value, options = {})
        begin
          coerced = Integer(value)
          success_message(coerced)
        rescue ArgumentError, TypeError
          error_message("debe ser un entero")
        end
      end

      def self.coerce(value, options = {})
        Integer(value)
      rescue ArgumentError, TypeError
        value
      end
    end

    # Regla para enumeración
    class Enum < BaseRule
      def self.validate(value, options = {})
        allowed_values = options[:values] || []
        
        if Array(allowed_values).include?(value)
          success_message(value)
        else
          error_message("debe ser uno de: #{Array(allowed_values).join(', ')}")
        end
      end
    end
  end
end