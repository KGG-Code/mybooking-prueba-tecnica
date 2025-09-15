# frozen_string_literal: true

module Validation
  module Rules
    class Integer < BaseRule
      def self.validate(value, options = {})
        # Si el valor es nil y no es nullable, es un error
        if value.nil?
          return error_message("debe ser un entero")
        end
        
        begin
          coerced = Integer(value)
          success_message(coerced)
        rescue ArgumentError, TypeError
          error_message("debe ser un entero")
        end
      end

      def self.coerce(value, options = {})
        return value if value.nil?
        Integer(value)
      rescue ArgumentError, TypeError
        value
      end
    end
  end
end