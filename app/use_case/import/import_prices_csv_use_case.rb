module UseCase
  module Import
    #
    # Use case to import prices from CSV
    #
    class ImportPricesCsvUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Service::ImportPrices] import_service
      # @param [Validation::Validator] validator
      # @param [Logger] logger
      #
      def initialize(import_service, validator, logger)
        @import_service = import_service
        @validator = validator
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [String] csv_path - Path to the CSV file to import
      #
      # @return [Result]
      #
      def perform(csv_path)
        begin
          # Validar que el archivo existe y es válido
          unless File.exist?(csv_path)
            @logger.error "ImportPricesCsvUseCase - perform - CSV file does not exist: #{csv_path}"
            return Result.new(success?: false, message: "CSV file does not exist")
          end

          unless File.size(csv_path) > 0
            @logger.error "ImportPricesCsvUseCase - perform - CSV file is empty: #{csv_path}"
            return Result.new(success?: false, message: "CSV file is empty")
          end

          @logger.info "ImportPricesCsvUseCase - perform - starting import from #{csv_path}"

          # Ejecutar la importación usando el import service
          @import_service.call(csv_path)
          
          # Verificar que la importación fue exitosa
          file_size = File.size(csv_path)
          @logger.info "ImportPricesCsvUseCase - perform - CSV imported successfully (#{file_size} bytes processed)"
          
          return Result.new(
            success?: true, 
            authorized?: true, 
            data: { 
              file_path: csv_path, 
              file_size: file_size,
              processed_at: Time.now.iso8601
            }
          )
        rescue => e
          @logger.error "ImportPricesCsvUseCase - perform - Error: #{e.message}"
          return Result.new(success?: false, message: e.message)
        end
      end

      private

      #
      # Validate CSV file format and content
      #
      # @param [String] csv_path - Path to the CSV file
      #
      # @return [Boolean] true if valid, false otherwise
      #
      def validate_csv_file(csv_path)
        begin
          # Verificar que es un archivo CSV válido
          CSV.foreach(csv_path, headers: true) do |row|
            # Validar que tiene las columnas mínimas requeridas
            required_headers = %w[category_code rental_location_name rate_type_name season_definition_name season_name time_measurement units]
            missing_headers = required_headers - row.headers.map(&:downcase)
            
            if missing_headers.any?
              @logger.error "ImportPricesCsvUseCase - validate_csv_file - Missing required headers: #{missing_headers.join(', ')}"
              return false
            end
            
            # Solo validar la primera fila para verificar estructura
            break
          end
          
          true
        rescue CSV::MalformedCSVError => e
          @logger.error "ImportPricesCsvUseCase - validate_csv_file - Malformed CSV: #{e.message}"
          false
        rescue => e
          @logger.error "ImportPricesCsvUseCase - validate_csv_file - Error reading CSV: #{e.message}"
          false
        end
      end

    end
  end
end