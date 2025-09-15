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

            # Repositorios
            price_repo        = Repository::PriceRepository.new
            category_repo     = Repository::CategoryRepository.new
            rl_repo           = Repository::RentalLocationRepository.new
            rt_repo           = Repository::RateTypeRepository.new
            crlrt_repo        = Repository::CategoryRentalLocationRateTypeRepository.new
            season_repo       = Repository::SeasonRepository.new
            price_def_repo    = Repository::PriceDefinitionRepository.new
            pd_units_resolver = Service::Resolvers::AllowedUnitsFromPriceDefinitionResolver.new(
              price_definition_repo: price_def_repo,
              logger: logger
            )
            
            # Repositorios
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
              prices_resource:              prices_resource,
              price_definition_resolver:    price_def_resolver,
              season_id_resolver:           season_id_resolver,
              time_measurement_parser:      tm_parser,
              price_definition_units_resolver: pd_units_resolver,
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

            payload = {
              message:  result.message,
              imported: result.imported,
              total:    result.total,
              errors:   result.errors # array de {row, values, reason}
            }

            status(result.success? ? 201 : 422)
            payload.to_json

          rescue => e
            logger&.error "[ImportController] #{e.class}: #{e.message}"
            halt 500, { error: 'Fallo inesperado en la importación' }.to_json
          end
        end

      end
    end
  end
end