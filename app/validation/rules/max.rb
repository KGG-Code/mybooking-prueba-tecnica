# frozen_string_literal: true

module Validation
  module Rules
    class Max < BaseRule
      def self.validate(value, options = {})
        max_value = options[:value]
        
        if value.is_a?(Numeric)
          if value <= max_value
            success_message(value)
          else
            error_message("debe ser ≤ #{max_value}")
          end
        else
          if value.to_s.length <= max_value
            success_message(value)
          else
            error_message("debe tener longitud ≤ #{max_value}")
          end
        end
      end
    end
  end
end