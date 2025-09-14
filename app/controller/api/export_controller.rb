require 'tempfile'

module Controller
  module Api
    module ExportController
      def self.registered(app)
        
        # Endpoint para descargar CSV de precios (TODOS los precios)
        app.get '/api/export/prices.csv' do
          
          content_type "text/csv"
          attachment "precios_export.csv"  # fuerza descarga

          # Crear archivo temporal
          tmp = Tempfile.new(['precios_export', '.csv'])
          tmp_path = tmp.path
          tmp.close # Cerrar el handle para que send_file pueda usarlo
          
          begin
            # Usar el use case para la exportación
            pricing_service = Service::PricingService.new
            season_repository = Repository::SeasonRepository.new
            export_service = Service::ExportPricesCsv.new(season_repository: season_repository)
            validator = Validation::Validator.new
            use_case = UseCase::Export::ExportPricesCsvUseCase.new(pricing_service, export_service, validator, logger)
            result = use_case.perform(tmp_path)
            
            if result.success?
              # Usar send_file y programar eliminación después de un tiempo razonable
              send_file tmp_path, disposition: :attachment, filename: "precios_export.csv"
              
              # Programar eliminación del archivo después de un tiempo
              Thread.new do
                sleep 30 # Esperar 30 segundos para que termine la descarga
                File.delete(tmp_path) if File.exist?(tmp_path)
              end
            else
              logger.error "Error en exportación: #{result.message}"
              raise Errors::ExportError.new("Error en la exportación: #{result.message}")
            end
          rescue => e
            # Eliminar archivo temporal si hay error
            File.delete(tmp_path) if File.exist?(tmp_path)
            raise e
          end
        end

        # Endpoint para obtener información sobre la exportación (JSON)
        app.get '/api/export/prices/info' do
          
          content_type :json
          
          Tempfile.create(['precios_info', '.csv']) do |tmp|
            pricing_service = Service::PricingService.new
            season_repository = Repository::SeasonRepository.new
            export_service = Service::ExportPricesCsv.new(season_repository: season_repository)
            validator = Validation::Validator.new
            use_case = UseCase::Export::ExportPricesCsvUseCase.new(pricing_service, export_service, validator, logger)
            result = use_case.perform(tmp.path)
            
            if result.success?
              # Usar los datos del use case en lugar de contar líneas del archivo
              response = {
                status: "success",
                total_records: result.data[:total_records],
                file_size_bytes: result.data[:file_size],
                export_timestamp: Time.now.iso8601
              }
              
              response.to_json
            else
              raise Errors::ExportError.new("Error obteniendo información de exportación: #{result.message}")
            end
          end # Archivo se elimina automáticamente aquí
        end
      end
    end
  end
end