# frozen_string_literal: true

module Validation
  module Rules
    class String < BaseRule
      def self.validate(value, options = {})
        success_message(value.to_s)
      end

      def self.coerce(value, options = {})
        value.to_s
      end
    end
  end
end