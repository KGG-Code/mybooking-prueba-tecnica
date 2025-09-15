# frozen_string_literal: true

module Validation
  module Rules
    class Email < BaseRule
      EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

      def self.validate(value, options = {})
        if EMAIL_REGEX.match?(value.to_s)
          success_message(value)
        else
          error_message("no es un email válido")
        end
      end
    end
  end
end