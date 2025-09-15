# frozen_string_literal: true

require 'ostruct'

module Adapters
  # Reader que aplana la salida de tu Service::PricingService#get_price_definitions(conditions).
  # - No mete filas en blanco (presentación ⇒ exporter).
  # - Puede resolver season_name vía un resolver inyectado.
  #
  # Yields OpenStruct con:
  #   rental_location_name, rate_type_name, category_code, category_name,
  #   price_definition_id, season_id, season_name, time_measurement, units,
  #   price, included_km, extra_km_price
  class PricingServiceReader
    def initialize(pricing_service, conditions: {}, season_name_resolver: nil, time_measurement_resolver: nil)
      @svc          = pricing_service
      @conditions   = conditions || {}
      @resolver     = season_name_resolver
      @tm_resolver  = time_measurement_resolver
    end

    def each
      rows = @svc.get_price_definitions(@conditions)

      rows.each do |row|
        rl_name  = fetch(row, 'rental_location_name')
        rt_name  = fetch(row, 'rate_type_name')
        cat_code = fetch(row, 'category_code')
        cat_name = fetch(row, 'category_name')
        pd_id    = fetch(row, 'price_definition_id')

        prices = (row['prices'] || row[:prices] || [])

        if prices.nil? || prices.empty?
          yield build_item(
            rl_name:, rt_name:, cat_code:, cat_name:, pd_id:,
            season_id: nil, time_measurement: nil, units: nil, price: nil,
            included_km: nil, extra_km_price: nil
          )
          next
        end

        prices.each do |p|
          season_id        = fetch(p, 'season_id')&.to_i
          time_measurement = fetch(p, 'time_measurement')&.to_i
          units            = fetch(p, 'units')&.to_i
          price            = to_numeric(fetch(p, 'price'))
          included_km      = fetch(p, 'included_km')&.to_i
          extra_km_price   = to_numeric(fetch(p, 'extra_km_price'))

          yield build_item(
            rl_name:, rt_name:, cat_code:, cat_name:, pd_id:,
            season_id:, time_measurement:, units:, price:,
            included_km:, extra_km_price:
          )
        end
      end
    end

    private

    def build_item(rl_name:, rt_name:, cat_code:, cat_name:, pd_id:,
                   season_id:, time_measurement:, units:, price:, included_km:, extra_km_price:)
      OpenStruct.new(
        rental_location_name: rl_name,
        rate_type_name:       rt_name,
        category_code:        cat_code,
        category_name:        cat_name,
        price_definition_id:  pd_id,
        season_id:            season_id,
        season_name:          resolve_season_name(season_id),
        time_measurement:     resolve_time_measurement(time_measurement),
        units:                units,
        price:                price,
        included_km:          included_km,
        extra_km_price:       extra_km_price
      )
    end

    def resolve_season_name(season_id)
      return 'Sin Temporada' if season_id.nil? || season_id == 0
      return 'Sin Temporada' unless @resolver
      @resolver.call(season_id) || "Temporada #{season_id}"
    end

    def resolve_time_measurement(time_measurement)
      return 'Sin Medida' if time_measurement.nil? || time_measurement == 0
      return 'Sin Medida' unless @tm_resolver
      @tm_resolver.call(time_measurement) || "Medida #{time_measurement}"
    end

    def fetch(h, key)
      h[key] || h[key.to_sym]
    end

    def to_numeric(v)
      return nil if v.nil?
      return v if v.is_a?(Numeric)
      v.to_s.tr(',', '.').to_f
    end
  end
end