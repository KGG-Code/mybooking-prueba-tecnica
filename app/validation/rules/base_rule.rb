# frozen_string_literal: true

module Validation
  module Rules
    # Regla base para todas las reglas de validación
    class BaseRule
      def self.validate(value, options = {})
        raise NotImplementedError, "Subclasses must implement #validate"
      end

      def self.coerce(value, options = {})
        value
      end

      protected

      def self.error_message(message)
        { success: false, value: nil, message: message }
      end

      def self.success_message(value)
        { success: true, value: value, message: nil }
      end
    end
  end
end