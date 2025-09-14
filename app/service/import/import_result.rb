module Service
  module Import
    #
    # Resultado consistente para operaciones de importación
    #
    class ImportResult
      attr_reader :success, :processed_rows, :skipped_rows, :errors, :message, :skipped_rows_details

      def initialize(success:, processed_rows: 0, skipped_rows: 0, errors: [], message: nil, skipped_rows_details: [])
        @success        = success
        @processed_rows = processed_rows
        @skipped_rows   = skipped_rows
        @errors         = errors
        @message        = message
        @skipped_rows_details = skipped_rows_details
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def to_hash
        {
          success: @success,
          processed_rows: @processed_rows,
          skipped_rows: @skipped_rows,
          errors: @errors,
          message: @message,
          skipped_rows_details: @skipped_rows_details
        }
      end
    end
  end
end