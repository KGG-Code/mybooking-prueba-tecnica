# frozen_string_literal: true

# Servicio para importar precios desde datos CSV procesados.
#
# Recibe un OpenStruct con datos "humanos" del CSV y devuelve [:ok, nil] o [:error, "reason"]

# TODO: mejoar el error handling, mas especiicaos, por ejemplo si rental_location no es valido, el error es que no encuentra price_definition

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
      price_definition    = @pd_res.call(row)
      return error("price_definition_not_found") unless price_definition
      
      # 2) Parse TM y units
      tm_code = @tm_parse.call(row.time_measurement)
      units   = int_or_nil(row.units)
      return error("invalid_time_measurement_or_units") if tm_code.nil? || units.nil?

      # 3) Resolver season
      season_id = @season_r.call(row.season_name) # nil si "Sin Temporada" o vacío
      return error("invalid_season_name") if season_id.is_a?(String)

      # 4) Validar coherencia entre season_id y price_definition.season_definition_id
      if season_id.nil? && price_definition.season_definition_id.present?
        return error("season_definition_mismatch: price_definition has season_definition but season_id is null")
      elsif season_id.present? && price_definition.season_definition_id.nil?
        return error("season_definition_mismatch: price_definition has no season_definition but season_id is present")
      end

      # 5) Regla de negocio: PD habilita TM y units
      allowed = @pd_units.call(price_definition, tm_code)
      @logger&.info("[ImportPrices] ALLOWED UNITS: #{allowed.inspect} for tm_code=#{tm_code}, units=#{units}")
      
      return error("unit_not_allowed_by_price_definition") unless allowed.include?(units)

      # 5) check if price is vaid float number
      return error("invalid_price") unless is_f(row.price)

      # 6) Persistir (upsert)
      attrs = {
        price_definition_id: price_definition.id,
        season_id:           season_id,
        time_measurement:    tm_code,
        units:               units,
        price:               row.price.to_f,
        included_km:         row.included_km.to_i,
        extra_km_price:      row.extra_km_price.to_f
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

    def is_f(v)
      return false if v.nil?
      s = v.to_s.strip
      return false if s.empty?
      s = s.tr(',', '.')
      /\A-?\d+(\.\d+)?\z/ === s
    end
  end
end
