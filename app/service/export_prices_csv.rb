# frozen_string_literal: true
require "csv"
module Service
    class ExportPricesCsv
    # Mapeo numérico->texto para salida human-readable
    TIME_MEAS_TEXT = {
        1 => "meses",
        2 => "dias",
        3 => "horas",
        4 => "minutos"
    }.freeze

    def initialize(logger: $stdout)
        @logger = logger
    end

    def call(csv_path, data: nil, logger: $stdout)
        run(csv_path, data)
    end

    def run(csv_path, data = nil)
        # Los datos deben ser proporcionados por el UseCase
        raise ArgumentError, "data parameter is required" if data.nil?
        
        # Escribimos el CSV con cabecera
        CSV.open(csv_path, "w", write_headers: true, headers: %w[
        category_code
        rental_location_name
        rate_type_name
        season_name
        time_measurement
        units
        price
        included_km
        extra_km_price
        ]) do |csv|
        data.each_with_index do |price_definition, index|
            # Agregar fila en blanco entre grupos (excepto el primero)
            csv << [] if index > 0
            
            # Procesar cada precio individual dentro de la price definition
            prices_array = price_definition['prices'] || price_definition[:prices] || []
            prices_array.each do |price|
            csv << [
                price_definition['category_code'] || price_definition[:category_code],
                price_definition['rental_location_name'] || price_definition[:rental_location_name],
                price_definition['rate_type_name'] || price_definition[:rate_type_name],
                get_season_name(price['season_id'] || price[:season_id]),
                TIME_MEAS_TEXT[price['time_measurement'] || price[:time_measurement]] || (price['time_measurement'] || price[:time_measurement]).to_s,
                price['units'] || price[:units],
                price['price'] || price[:price],
                price['included_km'] || price[:included_km],
                price['extra_km_price'] || price[:extra_km_price]
            ]
            end
        end
        end
        total_prices = data.sum { |pd| (pd['prices'] || pd[:prices] || []).length }
        log_message = "[INFO] Exportación finalizada en #{csv_path} - #{data.length} grupos, #{total_prices} precios exportados"
        
        if @logger.respond_to?(:info)
          @logger.info log_message
        else
          @logger.puts log_message
        end
    end

    private

    def get_season_name(season_id)
        # Mapeo básico de season_id a nombre de temporada
        # Puedes expandir esto según tus necesidades
        case season_id
        when 1 then "Alta"
        when 2 then "Media"
        when 3 then "Baja"
        when 4 then "Alta"
        when 5 then "Media"
        when 0, nil then "Sin Temporada"
        else "Temporada #{season_id}"
        end
    end

    end
  end