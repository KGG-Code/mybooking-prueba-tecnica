module Errors
    class UnauthorizedError < BaseError
        def initialize(message = "Unauthorized", details: nil)
        super(message, code: "unauthorized", status: 401, details: details)
        end
    end
end