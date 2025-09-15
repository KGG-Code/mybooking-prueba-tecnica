# frozen_string_literal: true

module Validation
  module Rules
    class Min < BaseRule
      def self.validate(value, options = {})
        min_value = options[:value]
        
        if value.is_a?(Numeric)
          if value >= min_value
            success_message(value)
          else
            error_message("debe ser ≥ #{min_value}")
          end
        else
          if value.to_s.length >= min_value
            success_message(value)
          else
            error_message("debe tener longitud ≥ #{min_value}")
          end
        end
      end
    end
  end
end