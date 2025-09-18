# frozen_string_literal: true
require 'sinatra/base'
require 'json'
require 'tempfile'
require_relative '../../validation/contracts/pricing_contracts'

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
            pd_units_resolver = Utils::Resolvers::AllowedUnitsFromPriceDefinitionResolver.new(
              logger: logger
            )
            pd_units_resolver.clear_cache!
            
            price_def_resolver = Utils::Resolvers::PriceDefinitionResolver.new(
              category_repo: Repository::CategoryRepository.new,
              rental_location_repo: Repository::RentalLocationRepository.new,
              rate_type_repo: Repository::RateTypeRepository.new,
              crlrt_repo: Repository::CategoryRentalLocationRateTypeRepository.new,
              logger: logger
            )

            season_id_resolver = Utils::Resolvers::SeasonIdResolver.new(
              season_repo: Repository::SeasonRepository.new,
              logger: logger
            )

            tm_parser = Service::TimeMeasurementParser.new

            prices_resource = Resources::PricesResource.new(
              price_repository: Repository::PriceRepository.new,
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

            use_case = UseCase::Import::ImportPricesUseCase.new(
              reader: reader,
              importer: importer,
              logger: logger
            )

            result = use_case.perform

            payload = {
              success:  result.success?,
              message:  result.message,
              imported: result.imported,
              total:    result.total,
              errors:   result.errors, # array de {row, values, reason}
              status:   result.status
            }

            # Determinar código de estado HTTP basado en el resultado
            http_status = case result.status
            when :success
              201  # Created - importación completamente exitosa
            when :partial_success
              200  # OK - importación parcialmente exitosa
            when :error
              422  # Unprocessable Entity - no se pudo importar nada
            else
              500  # Internal Server Error - estado desconocido
            end

            status(http_status)
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