module Errors
class ValidationError < StandardError
    attr_reader :errors, :status
    def initialize(errors, status: 422)
      @errors = errors
      @status = status
      super("Validation failed")
    end
  end
end
