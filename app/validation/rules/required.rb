# frozen_string_literal: true

module Validation
  module Rules
    class Required < BaseRule
      def self.validate(value, options = {})
        if Helpers.present?(value)
          success_message(value)
        else
          error_message("es obligatorio")
        end
      end
    end
  end
end