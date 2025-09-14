module Controller
  module Api
    module ImportController
      def self.registered(app)
        # Endpoint para subir CSV de precios
        app.post '/api/import/prices' do
          file = params.dig(:file, :tempfile) or halt 400, "Archivo requerido"
          
          begin
            price_repository = Repository::PriceRepository.new
            import_service = Service::ImportPrices.new(price_repository, logger: logger)
            validator = Validation::Validator.new
            use_case = UseCase::Import::ImportPricesCsvUseCase.new(import_service, validator, logger)
            result = use_case.perform(file.path)
            
            if result.success?
              content_type :json
              { status: "success", message: "Importación completada" }.to_json
            else
              logger.error "Error en importación: #{result.message}"
              halt 500, { status: "error", message: result.message }.to_json
            end
          rescue => e
            logger.error "Error en importación: #{e.message}"
            halt 500, { status: "error", message: e.message }.to_json
          end
        end

        # Endpoint para mostrar formulario de importación (opcional)
        app.get '/imports/prices' do
          erb :import_prices_form
        end

        # Endpoint para obtener información sobre el formato de importación
        app.get '/api/import/prices/info' do
          content_type :json
          
          response = {
            status: "success",
            csv_format: {
              required_headers: [
                "category_code",
                "rental_location_name", 
                "rate_type_name",
                "season_name",
                "time_measurement",
                "units"
              ],
              optional_headers: [
                "price",
                "included_km",
                "extra_km_price"
              ],
              time_measurement_values: [
                "meses",
                "dias", 
                "horas",
                "minutos"
              ],
              description: "CSV format requirements and valid values"
            },
            example_file_url: "/api/export/prices.csv"
          }
          
          response.to_json
        end

        # Endpoint para descargar CSV de precios (TODOS los precios)
        app.get '/api/exports/prices.csv' do
          content_type "text/csv"
          attachment "precios_export.csv"  # fuerza descarga

          tmp = nil
          begin
            tmp = File.join(Dir.tmpdir, "precios_export_#{Time.now.to_i}.csv")
            ExportPrices.call(tmp, logger: logger)
            send_file tmp
          rescue => e
            logger.error "Error en exportación: #{e.message}"
            halt 500, "Error en la exportación: #{e.message}"
          ensure
            # Limpiar archivo temporal después de un tiempo (no inmediatamente)
            if tmp && File.exist?(tmp)
              Thread.new do
                sleep 5  # Esperar 5 segundos antes de eliminar
                File.delete(tmp) if File.exist?(tmp)
              end
            end
          end
        end

        # Endpoint para mostrar página de exportación
        app.get '/exports/prices' do
          erb :export_prices_form
        end
      end
    end
  end
end