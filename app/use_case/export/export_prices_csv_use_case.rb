module UseCase
  module Export
    #
    # Use case to export prices to CSV
    #
    class ExportPricesCsvUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Service::ExportPrices] export_service
      # @param [Logger] logger
      #
      def initialize(pricing_service, export_service, validator, logger)
        @pricing_service = pricing_service
        @export_service = export_service
        @validator = validator
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [String] csv_path - Path where to save the CSV file
      #
      # @return [Result]
      #
      def perform(csv_path)
        begin
          # Cargar datos usando el pricing service
          conditions = build_conditions({})
          price_definitions = @pricing_service.get_price_definitions_paginated(conditions)
          @logger.info "ExportPricesCsvUseCase - perform - loaded #{price_definitions.length} price definitions"

          # Crear el CSV usando el export service con los datos cargados
          @export_service.call(csv_path, data: price_definitions, logger: @logger)
          
          # Verificar que el archivo se creó correctamente
          if File.exist?(csv_path) && File.size(csv_path) > 0
            file_size = File.size(csv_path)
            @logger.info "ExportPricesCsvUseCase - perform - CSV exported successfully (#{file_size} bytes)"
            return Result.new(success?: true, authorized?: true, data: { file_path: csv_path, file_size: file_size})
          else
            @logger.error "ExportPricesCsvUseCase - perform - CSV file was not created or is empty"
            return Result.new(success?: false, message: "CSV file was not created or is empty")
          end
        rescue => e
          @logger.error "ExportPricesCsvUseCase - perform - Error: #{e.message}"
          return Result.new(success?: false, message: e.message)
        end
      end

      private

      #
      # Build conditions for the query
      #
      # @param [Hash] processed_params - Processed parameters
      #
      # @return [Hash] Conditions hash
      #
      def build_conditions(processed_params)
        conditions = {}
        conditions[:page] = processed_params[:page] unless processed_params[:page].nil?
        conditions[:per_page] = processed_params[:per_page] unless processed_params[:per_page].nil?
        conditions
      end


    end
  end
end