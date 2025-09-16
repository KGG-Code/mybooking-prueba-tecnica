# frozen_string_literal: true

module Validation
  module Rules
    class Numeric < BaseRule
      def self.validate(value, options = {})
        begin
          coerced = Float(value)
          success_message(coerced)
        rescue ArgumentError, TypeError
          error_message("debe ser numérico")
        end
      end

      def self.coerce(value, options = {})
        Float(value)
      rescue ArgumentError, TypeError
        value
      end
    end
  end
end