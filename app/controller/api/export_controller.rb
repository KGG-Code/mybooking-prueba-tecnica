# frozen_string_literal: true
require 'sinatra/base'
require 'sinatra/streaming'
require 'tempfile'

module Controller
  module Api
    module ExportController
      def self.registered(app)
        app.helpers Sinatra::Streaming

        # Helpers locales para filtrar params permitidos hacia service
        app.helpers do
          def export_conditions_from_params
            allowed = %i[
              rental_location_id
              rate_type_id
              season_definition_id
              season_id
              unit
              page
              per_page
            ]
            cond = {}
            allowed.each do |k|
              cond[k] = params[k.to_s] if params.key?(k.to_s)
            end
            # Normalizaciones mínimas
            cond[:page]      = cond[:page].to_i      if cond[:page]
            cond[:per_page]  = cond[:per_page].to_i  if cond[:per_page]
            cond[:unit]      = cond[:unit].to_i      if cond[:unit]
            cond[:season_id] = cond[:season_id].to_i if cond[:season_id]
            cond
          end
        end

        # =========================
        # CSV: /api/export/prices.csv
        # =========================
        app.get '/api/export/prices.csv' do
          content_type 'text/csv; charset=utf-8'
          attachment  'precios_export.csv'
          headers 'Cache-Control' => 'no-store'

          tmp = Tempfile.create(['precios_export', '.csv'])
          tmp_path = tmp.path
          tmp.close

          begin
            # 1) Construcción de dependencias (en orden)
            pricing_service   = Service::PricingService.new
            season_repository = Repository::SeasonRepository.new
            resolver          = Utils::Resolvers::SeasonNameResolver.new(season_repository: season_repository)
            tm_resolver       = Utils::Resolvers::TimeMeasurementResolver.new
            reader            = Adapters::PricingReaderFromService.new(
                                  pricing_service,
                                  conditions: export_conditions_from_params,
                                  season_name_resolver: resolver,
                                  time_measurement_resolver: tm_resolver
                                )
            exporter          = Service::ExportPricesCsv.new
            validator         = Validation::Validator.new   # <-- ¡AQUÍ se define!

            # 2) Use case con TODAS las deps
            use_case = UseCase::Export::ExportPricesUseCase.new(
              reader: reader,
              exporter: exporter,
              validator: validator,
              logger: logger
            )

            # 3) Ejecutar y pasar input al validador (si lo necesita)
            result = use_case.perform(tmp_path, input: export_conditions_from_params)
            halt 422, "Error en la exportación: #{result.message}" unless result.success?

            # 4) Streaming del archivo + cleanup
            stream do |out|
              begin
                File.open(tmp_path, 'rb') do |f|
                  chunk_size = 64 * 1024
                  while (chunk = f.read(chunk_size))
                    out << chunk
                    out.flush if out.respond_to?(:flush)
                  end
                end
              ensure
                File.delete(tmp_path) rescue nil
              end
            end
          rescue => e
            File.delete(tmp_path) rescue nil
            raise
          end
        end
      end
    end
  end
end