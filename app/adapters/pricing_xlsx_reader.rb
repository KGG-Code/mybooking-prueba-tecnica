# frozen_string_literal: true

require 'roo'
require 'ostruct'

# Adapter para leer archivos XLSX de precios y convertirlos a objetos OpenStruct.
module Adapters
  class PricingXlsxReader
    # Cabeceras esperadas:
    # category_code, rental_location_name, rate_type_name, season_name,
    # time_measurement, units, price, included_km, extra_km_price
    def initialize(file)
      @file = file
    end

    def each
      xlsx = Roo::Spreadsheet.open(@file)
      sheet = xlsx.sheet(0) # Primera hoja
      
      # Obtener las cabeceras de la primera fila
      headers = sheet.row(1).map(&:to_s)
      
      # Crear un hash para mapear nombres de columna a índices
      header_map = {}
      headers.each_with_index do |header, index|
        header_map[header.downcase.strip] = index
      end
      
      row_no = 2 # Empezar desde la fila 2 (después de las cabeceras)
      
      # Iterar sobre todas las filas de datos
      (2..sheet.last_row).each do |row_index|
        row_data = sheet.row(row_index)
        
        # Convertir fila a hash usando los índices de las cabeceras
        h = {}
        header_map.each do |header_name, index|
          h[header_name] = row_data[index] if index < row_data.length
        end
        
        # Saltar filas totalmente vacías
        next if blank_row?(h)
        
        yield OpenStruct.new(
          _row_number:          row_no,
          category_code:        str_or_nil(h['category_code']),
          rental_location_name: str_or_nil(h['rental_location_name']),
          rate_type_name:       str_or_nil(h['rate_type_name']),
          season_name:          str_or_nil(h['season_name']),
          time_measurement:     h['time_measurement'],         # puede ser "2" o "días"
          units:                to_i_or_nil(h['units']),
          price:                to_f_or_nil(h['price']),
          included_km:          to_i_or_nil(h['included_km']),
          extra_km_price:       to_f_or_nil(h['extra_km_price'])
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

    def to_f_or_nil(v)
      return nil if blank?(v)
      s = v.to_s.strip.tr(',', '.')
      /\A-?\d+(\.\d+)?\z/ === s ? s.to_f : nil
    end
  end
end