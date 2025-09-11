module Errors
    class NotFoundError < BaseError
        def initialize(message = "Resource not found", details: nil)
        super(message, code: "not_found", status: 404, details: details)
        end
    end
end