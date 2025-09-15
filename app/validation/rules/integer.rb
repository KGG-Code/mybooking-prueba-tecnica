# frozen_string_literal: true

module Validation
  module Rules
    class Integer < BaseRule
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
  end
end