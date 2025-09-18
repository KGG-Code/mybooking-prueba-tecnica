# frozen_string_literal: true

require 'csv'

module Service
  class ExportPricesCsv
    # Firma flexible:
    # - write(io, enum_proc)
    # - write(io, enum_proc, grouped: true)
    # - write(io, reader)                    # donde reader responde a #each
    # - write(io, reader, grouped: true)
    def write(io, source, *rest)
      options  = rest.last.is_a?(Hash) ? rest.last : {}
      grouped  = !!options[:grouped]

      enum_proc =
        if source.respond_to?(:call) # Proc/lambda
          source
      elsif source.respond_to?(:each) # Reader
        ->(&blk) { source.each(&blk) }
      else
        raise ArgumentError, "ExportPricesCsv#write expects a Proc or a reader responding to #each"
        end

      csv = CSV.new(io, col_sep: ',', row_sep: :auto, force_quotes: true)

      csv << %w[
        category_code
        rental_location_name
        rate_type_name
        season_name
        time_measurement
        units
        price
        included_km
        extra_km_price
      ]

      last_key = nil

      enum_proc.call do |row|
        if grouped
          current_key = [row.category_code, row.rental_location_name, row.rate_type_name, row.time_measurement]
          if last_key && current_key != last_key
            csv << [] # línea en blanco entre grupos
          end
          last_key = current_key
        end

        csv << [
          row.category_code,
          row.rental_location_name,
          row.rate_type_name,
          row.season_name,
          row.time_measurement,
          row.units,
          numeric(row.price),
          row.included_km,
          numeric(row.extra_km_price)
        ]
      end

      csv.close
    end

    private

    def numeric(number)
      return nil if number.nil?
      number.is_a?(Numeric) ? number : number.to_s.tr(',', '.').to_f
    end
  end
end
