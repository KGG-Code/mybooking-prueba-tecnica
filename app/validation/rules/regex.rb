# frozen_string_literal: true

module Validation
  module Rules
    class Regex < BaseRule
      def self.validate(value, options = {})
        pattern = options[:pattern]
        
        if pattern === value.to_s
          success_message(value)
        else
          error_message("formato inválido")
        end
      end
    end
  end
end