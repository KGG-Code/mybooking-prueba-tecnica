# frozen_string_literal: true

module UseCase
  module Import
    class ImportPricesCsvUseCase
      Result = Struct.new(:success?, :message, keyword_init: true)

      def initialize(reader:, importer:, validator:, logger: nil)
        @reader    = reader      # each_row { |row| ... }
        @importer  = importer
        @validator = validator
        @logger    = logger
      end

      def perform
        safe_validate!

        count = 0
        @reader.each_row do |row|
          @importer.import(row)
          count += 1
        end

        Result.new(success?: true, message: "Importadas #{count} filas")
      rescue Validation::Error => e
        @logger&.warn("[ImportPricesCsvUseCase] validation failed: #{e.message}")
        Result.new(success?: false, message: e.message)
      rescue => e
        @logger&.error("[ImportPricesCsvUseCase] unexpected: #{e.class}: #{e.message}")
        Result.new(success?: false, message: 'Fallo inesperado en la importación')
      end

      private

      def safe_validate!
        return unless @validator.respond_to?(:validate!)
        arity = @validator.method(:validate!).arity
        arity == 0 ? @validator.validate! : @validator.validate!({})
      end
    end
  end
end



#module UseCase
#  module Import
#    #
#    # Use case to import prices from CSV
#    #
#    class ImportPricesCsvUseCase
#
#      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)
#
#      #
#      # Initialize the use case
#      #
#      # @param [Service::ImportPrices] import_service
#      # @param [Logger] logger
#      #
#      def initialize(import_service, logger)
#        @import_service = import_service
#        @logger = logger
#      end
#
#      #
#      # Perform the use case
#      #
#      # @param [String] csv_path - Path to the CSV file to import
#      #
#      # @return [Result]
#      #
#      def perform(csv_path)
#        begin
#          @logger.info "ImportPricesCsvUseCase - perform - starting import from #{csv_path}"
#
#          # Ejecutar la importación usando el import service
#          result = @import_service.call(csv_path)
#          
#          if result.success?
#            @logger.info "ImportPricesCsvUseCase - perform - CSV imported successfully. Processed: #{result.processed_rows}, Skipped: #{result.skipped_rows}"
#            return Result.new(
#              success?: true, 
#              authorized?: true, 
#              data: { 
#                file_path: csv_path, 
#                processed_rows: result.processed_rows,
#                skipped_rows: result.skipped_rows,
#                errors: result.errors,
#                skipped_rows_details: result.skipped_rows_details,
#                processed_at: Time.now.iso8601
#              }
#            )
#          else
#            @logger.error "ImportPricesCsvUseCase - perform - Import failed: #{result.message}"
#            return Result.new(success?: false, message: result.message)
#          end
#        rescue => e
#          @logger.error "ImportPricesCsvUseCase - perform - Error: #{e.message}"
#          return Result.new(success?: false, message: e.message)
#        end
#      end
#
#    end
#  end
#end