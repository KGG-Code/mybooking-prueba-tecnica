module Controller
  module Api
    module ImportController
      def self.registered(app)
        
        # Endpoint para subir CSV de precios
        app.post '/api/import/prices' do
          logger.info "=== IMPORT CONTROLLER START ==="
          file = params.dig(:file, :tempfile) or halt 400, "Archivo requerido"
          
          # Crear repositories
          price_repository                              = Repository::PriceRepository.new
          category_repository                           = Repository::CategoryRepository.new
          rental_location_repository                    = Repository::RentalLocationRepository.new
          rate_type_repository                          = Repository::RateTypeRepository.new
          season_repository                             = Repository::SeasonRepository.new
          price_definition_repository                   = Repository::PriceDefinitionRepository.new
          category_rental_location_rate_type_repository = Repository::CategoryRentalLocationRateTypeRepository.new
          
          # Crear servicios especializados
          csv_validator   = Service::Import::CsvValidator.new(logger: logger)
          data_mapper     = Service::Import::DataMapper.new(logger: logger)
          entity_finder   = Service::Import::EntityFinder.new(
            category_repository, 
            rental_location_repository, 
            rate_type_repository,
            season_repository,
            price_definition_repository,
            category_rental_location_rate_type_repository,
            logger: logger
          )
          price_persister = Service::Import::PricePersister.new(price_repository, logger: logger)
          
          # Crear servicio principal
          import_service = Service::ImportPrices.new(
            csv_validator: csv_validator,
            data_mapper: data_mapper,
            entity_finder: entity_finder,
            price_persister: price_persister,
            logger: logger
          )
          
          # Crear use case
          use_case = UseCase::Import::ImportPricesCsvUseCase.new(import_service, logger)
          result = use_case.perform(file.path)
          
          if result.success?
            content_type :json
            { 
              status: "success", 
              message: "Importación completada",
              processed_rows: result.data[:processed_rows],
              skipped_rows: result.data[:skipped_rows],
              skipped_rows_details: result.data[:skipped_rows_details]
            }.to_json
          else
            content_type :json
            { 
              status: "error", 
              message: result.message
            }.to_json
          end
        end

        # Endpoint para mostrar formulario de importación
        app.get '/imports/prices' do
          erb :import_prices_form
        end
      
      end
    end
  end
end