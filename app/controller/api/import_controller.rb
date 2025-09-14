# frozen_string_literal: true
require 'sinatra/base'
require 'json'
require 'tempfile'

module Controller
  module Api
    module ImportController
      def self.registered(app)

        app.post '/api/import/prices' do
          content_type 'application/json; charset=utf-8'

          unless params[:file] && (tmpfile = params[:file][:tempfile]) && params[:file][:filename]
            halt 400, { error: 'No se envió ningún archivo' }.to_json
          end

          filename = params[:file][:filename]
          ext      = File.extname(filename).downcase

          begin
            reader =
              case ext
              when '.csv'  then Adapters::PricingCsvReader.new(tmpfile)
              #when '.xlsx' then Adapters::PricingXlsxReader.new(tmpfile)
              else
                halt 415, { error: "Formato no soportado: #{ext}. Usa .csv o .xlsx" }.to_json
              end

            # Repositorios (heredan de BaseRepository)
            price_repo   = Repository::PriceRepository.new
            category_repo = Repository::CategoryRepository.new
            rl_repo       = Repository::RentalLocationRepository.new
            rt_repo       = Repository::RateTypeRepository.new
            crlrt_repo    = Repository::CategoryRentalLocationRateTypeRepository.new
            season_repo   = Repository::SeasonRepository.new

            # Resolvers/recursos basados en repos
            price_def_resolver = Service::Resolvers::PriceDefinitionResolver.new(
              category_repo: category_repo,
              rental_location_repo: rl_repo,
              rate_type_repo: rt_repo,
              crlrt_repo: crlrt_repo,
              logger: logger
            )

            season_id_resolver = Service::Resolvers::SeasonIdResolver.new(
              season_repo: season_repo,
              logger: logger
            )

            tm_parser = Service::TimeMeasurementParser.new

            prices_resource = Resources::PricesResource.new(
              price_repository: price_repo,
              logger: logger
            )

            importer = Service::ImportPrices.new(
              prices_resource: prices_resource,
              price_definition_resolver: price_def_resolver,
              season_id_resolver: season_id_resolver,
              time_measurement_parser: tm_parser,
              logger: logger
            )

            validator = Validation::Validator.new

            use_case = UseCase::Import::ImportPricesCsvUseCase.new(
              reader: reader,
              importer: importer,
              validator: validator,
              logger: logger
            )

            result = use_case.perform

            if result.success?
              status 201
              { message: result.message || 'Importación completada' }.to_json
            else
              halt 422, { error: result.message }.to_json
            end

          rescue => e
            logger&.error "[ImportController] #{e.class}: #{e.message}"
            halt 500, { error: 'Fallo inesperado en la importación' }.to_json
          end
        end

      end
    end
  end
end


#module Controller
#  module Api
#    module ImportController
#      def self.registered(app)
#        
#        # Endpoint para subir CSV de precios
#        app.post '/api/import/prices' do
#          logger.info "=== IMPORT CONTROLLER START ==="
#          file = params.dig(:file, :tempfile) or halt 400, "Archivo requerido"
#          
#          # Crear repositories
#          price_repository                              = Repository::PriceRepository.new
#          category_repository                           = Repository::CategoryRepository.new
#          rental_location_repository                    = Repository::RentalLocationRepository.new
#          rate_type_repository                          = Repository::RateTypeRepository.new
#          season_repository                             = Repository::SeasonRepository.new
#          price_definition_repository                   = Repository::PriceDefinitionRepository.new
#          category_rental_location_rate_type_repository = Repository::CategoryRentalLocationRateTypeRepository.new
#          
#          # Crear servicios especializados
#          csv_validator   = Service::Import::CsvValidator.new(logger: logger)
#          data_mapper     = Service::Import::DataMapper.new(logger: logger)
#          entity_finder   = Service::Import::EntityFinder.new(
#            category_repository, 
#            rental_location_repository, 
#            rate_type_repository,
#            season_repository,
#            price_definition_repository,
#            category_rental_location_rate_type_repository,
#            logger: logger
#          )
#          price_persister = Service::Import::PricePersister.new(price_repository, logger: logger)
#          
#          # Crear servicio principal
#          import_service = Service::ImportPrices.new(
#            csv_validator: csv_validator,
#            data_mapper: data_mapper,
#            entity_finder: entity_finder,
#            price_persister: price_persister,
#            logger: logger
#          )
#          
#          # Crear use case
#          use_case = UseCase::Import::ImportPricesCsvUseCase.new(import_service, logger)
#          result = use_case.perform(file.path)
#          
#          if result.success?
#            content_type :json
#            { 
#              status: "success", 
#              message: "Importación completada",
#              processed_rows: result.data[:processed_rows],
#              skipped_rows: result.data[:skipped_rows],
#              skipped_rows_details: result.data[:skipped_rows_details]
#            }.to_json
#          else
#            content_type :json
#            { 
#              status: "error", 
#              message: result.message
#            }.to_json
#          end
#        end
#
#        # Endpoint para mostrar formulario de importación
#        app.get '/imports/prices' do
#          erb :import_prices_form
#        end
#      
#      end
#    end
#  end
#end