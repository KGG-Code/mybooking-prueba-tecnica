module Errors
  #
  # Error específico para operaciones de exportación
  #
  class ExportError < BaseError
    def initialize(message = "Export operation failed", details = nil)
      super(message, details)
    end
  end
end