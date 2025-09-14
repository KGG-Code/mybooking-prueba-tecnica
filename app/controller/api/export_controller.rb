# frozen_string_literal: true
require 'sinatra/base'
require 'sinatra/streaming'
require 'tempfile'
require 'csv'

module Controller
  module Api
    module ExportController
      def self.registered(app)
        app.helpers Sinatra::Streaming

        # Endpoint para descargar CSV de precios (TODOS los precios)
        app.get '/api/export/prices.csv' do
          content_type 'text/csv; charset=utf-8'
          attachment  'precios_export.csv'
          headers 'Cache-Control' => 'no-store'

          # Crear archivo temporal
          tmp = Tempfile.create(['precios_export', '.csv'])
          tmp_path = tmp.path
          tmp.close

          begin
            # Dependencias (ajusta a tu DI)
            pricing_service   = Service::PricingService.new
            season_repository = Repository::SeasonRepository.new
            export_service    = Service::ExportPricesCsv.new(season_repository: season_repository)
            validator         = Validation::Validator.new

            use_case = UseCase::Export::ExportPricesCsvUseCase.new(
              pricing_service,
              export_service,
              validator,
              logger
            )

            # Generar CSV en disco (tmp_path)
            result = use_case.perform(tmp_path)
            unless result.success?
              logger.error "Error en exportación: #{result.message}"
              halt 500, "Error en la exportación: #{result.message}"
            end

            # Streaming manual + cleanup garantizado
            stream do |out|
              begin
                # Copiamos en chunks usando << (no write)
                File.open(tmp_path, 'rb') do |f|
                  # Opcional: si quieres BOM UTF-8 para Excel Windows:
                  # out << "\uFEFF"

                  chunk_size = 64 * 1024 # 64 KiB
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
