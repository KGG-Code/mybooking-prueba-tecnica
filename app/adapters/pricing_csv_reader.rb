# frozen_string_literal: true

require 'csv'
require 'ostruct'

# Adapter para leer archivos CSV de precios y convertirlos a objetos OpenStruct.
module Adapters
  class PricingCsvReader
    # Cabeceras esperadas:
    # category_code, rental_location_name, rate_type_name, season_name,
    # time_measurement, units, price, included_km, extra_km_price
    def initialize(file)
      @file = file
    end

    def each
      # Leer el contenido del archivo y remover BOM si existe
      content = @file.read
      content = content.force_encoding('UTF-8')
      content = content.sub(/\A\xEF\xBB\xBF/, '') # Remover BOM UTF-8
      
      csv = CSV.new(content, headers: true, skip_blanks: true)
      row_no = 2 # asumiendo la fila 1 es la cabecera

      csv.each do |r|
        h = r.to_h.transform_keys(&:to_s)

        # Saltar filas totalmente vacías (no se procesan ni se reportan)
        next if blank_row?(h)

        yield OpenStruct.new(
          _row_number:          row_no,
          category_code:        str_or_nil(h['category_code']),
          rental_location_name: str_or_nil(h['rental_location_name']),
          rate_type_name:       str_or_nil(h['rate_type_name']),
          season_name:          str_or_nil(h['season_name']),
          time_measurement:     h['time_measurement'],         # puede ser "2" o "días"
          units:                to_i_or_nil(h['units']),
          price:                to_f_or_original(h['price']),
          included_km:          to_i_or_nil(h['included_km']),
          extra_km_price:       to_f_or_original(h['extra_km_price'])
        )

        row_no += 1
      end
    end

    private

    def blank_row?(hash)
      keys = %w[
        category_code rental_location_name rate_type_name season_name
        time_measurement units price included_km extra_km_price
      ]
      keys.all? { |k| blank?(hash[k]) }
    end

    def blank?(v)
      v.nil? || v.to_s.strip.empty?
    end

    def str_or_nil(v)
      return nil if blank?(v)
      v.to_s.strip
    end

    def to_i_or_nil(v)
      return nil if blank?(v)
      s = v.to_s.strip
      /\A-?\d+\z/ === s ? s.to_i : nil
    end

    def to_f_or_original(v)
      return v if blank?(v)
      s = v.to_s.strip.tr(',', '.')
      /\A-?\d+(\.\d+)?\z/ === s ? s.to_f : v
    end
  end
end