# frozen_string_literal: true

module Errors
  class ExportError < BaseError
    def initialize(message = "Export failed", code: "export_error", status: 422, details: nil)
      super(message, code: code, status: status, details: details)
    end
  end
end