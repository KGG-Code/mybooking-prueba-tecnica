module Errors
    class ValidationError < BaseError
        def initialize(message = "Validation failed", details: nil)
        super(message, code: "validation_error", status: 422, details: details)
        end
    end
end