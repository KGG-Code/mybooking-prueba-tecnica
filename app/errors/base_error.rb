module Errors
    class BaseError < StandardError
        attr_reader :code, :status, :details
    
        def initialize(message = "Unexpected error", code: "internal_error", status: 500, details: nil)
        super(message)
        @code    = code
        @status  = status
        @details = details
        end
    end
end