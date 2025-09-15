# frozen_string_literal: true

module Validation
  module Rules
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