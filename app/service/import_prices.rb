# frozen_string_literal: true

module Service
  class ImportPrices
    def initialize(
      prices_resource:,
      price_definition_resolver:,
      season_id_resolver:,
      time_measurement_parser:,
      price_definition_units_resolver:,  # AllowedUnitsFromPriceDefinitionResolver
      logger: nil
    )
      @prices    = prices_resource
      @pd_res    = price_definition_resolver
      @season_r  = season_id_resolver
      @tm_parse  = time_measurement_parser
      @pd_units  = price_definition_units_resolver
      @logger    = logger
    end

    # row: OpenStruct con columnas “humanas”; devuelve [:ok, nil] o [:error, "reason"]
    def import(row)
      # 1) Resolver PD
      price_definition_id = @pd_res.call(
        category_code:        row.category_code,
        rental_location_name: row.rental_location_name,
        rate_type_name:       row.rate_type_name
      )
      return error("price_definition_not_found") unless price_definition_id

      # 2) Parse TM y units
      tm_code = @tm_parse.call(row.time_measurement)
      units   = int_or_nil(row.units)
      return error("invalid_time_measurement_or_units") if tm_code.nil? || units.nil?

      # 3) Regla de negocio: PD habilita TM y units
      allowed = @pd_units.units_for(price_definition_id: price_definition_id, time_measurement: tm_code)
      return error("unit_not_allowed_by_price_definition") unless allowed.include?(units)

      # 4) Resolver season
      season_id = @season_r.call(row.season_name) # nil si "Sin Temporada" o vacío

      # 5) Persistir (upsert)
      attrs = {
        price_definition_id: price_definition_id,
        season_id:           season_id,
        time_measurement:    tm_code,
        units:               units,
        price:               to_f_or_nil(row.price),
        included_km:         int_or_nil(row.included_km),
        extra_km_price:      to_f_or_nil(row.extra_km_price)
      }

      ok = @prices.upsert(attrs)
      return error("persistence_failed") unless ok

      [:ok, nil]
    rescue => e
      @logger&.error("[ImportPrices] #{e.class}: #{e.message}")
      error("unexpected_error")
    end

    private

    def error(code) = [:error, code]

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
