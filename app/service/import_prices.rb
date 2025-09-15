# frozen_string_literal: true

module Service
  class ImportPrices
    def initialize(
      prices_resource:,
      price_definition_resolver:,
      season_id_resolver:,
      time_measurement_parser:,
      logger: nil
    )
      @prices   = prices_resource
      @pd_res   = price_definition_resolver
      @season_r = season_id_resolver
      @tm_parse = time_measurement_parser
      @logger   = logger
    end

    # row: OpenStruct con columnas “humanas”
    def import(row)
      price_definition_id = @pd_res.call(
        category_code:        row.category_code,
        rental_location_name: row.rental_location_name,
        rate_type_name:       row.rate_type_name
      )

      unless price_definition_id
        @logger&.warn "[ImportPrices] price_definition no encontrado para [#{row.category_code}/#{row.rental_location_name}/#{row.rate_type_name}]"
        return false
      end

      season_id    = @season_r.call(row.season_name)
      
      @logger&.info "[ImportPrices] BEFORE parser call - time_measurement: '#{row.time_measurement}' (class: #{row.time_measurement.class})"
      @logger&.info "[ImportPrices] parser object: #{@tm_parse.inspect} (class: #{@tm_parse.class})"
      
      tm_code = @tm_parse.call(row.time_measurement)
      
      @logger&.info "[ImportPrices] AFTER parser call - parsed result: #{tm_code.inspect} (class: #{tm_code.class})"

      attrs = {
        price_definition_id: price_definition_id,
        season_id:           season_id,                       # nil si Sin Temporada
        time_measurement:    tm_code,
        units:               int_or_nil(row.units),
        price:               to_f_or_nil(row.price),
        included_km:         int_or_nil(row.included_km),
        extra_km_price:      to_f_or_nil(row.extra_km_price)
      }

      ok = @prices.upsert(attrs)
      @logger&.warn("[ImportPrices] fallo upsert #{attrs.inspect}") unless ok
      ok
    end

    private

    def int_or_nil(v)
      return nil if v.nil?
      s = v.to_s.strip
      return nil if s.empty?
      /\A-?\d+\z/ === s ? s.to_i : nil
    end

    def to_f_or_nil(v)
      return nil if v.nil?
      s = v.to_s.strip
      return nil if s.empty?
      s.tr(',', '.').to_f
    end
  end
end