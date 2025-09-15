# frozen_string_literal: true

module Resources
    class PricesResource
      # Contrato estable: upsert(attrs) -> true/false
      # attrs: :price_definition_id, :season_id, :time_measurement, :units, :price, :included_km, :extra_km_price
      def initialize(price_repository:, logger: nil)
        @repo   = price_repository
        @logger = logger
      end
  
      def upsert(attrs)
        key = {
          price_definition_id: attrs[:price_definition_id],
          season_id:           attrs[:season_id],
          time_measurement:    attrs[:time_measurement],
          units:               attrs[:units]
        }

        record = @repo.first(key)

        if record
          @repo.update(record.id, attrs) # Usar el ID del registro encontrado
          true
        else
          !!@repo.create(attrs)
        end
      rescue => e
        @logger&.error("[PricesResource#upsert] #{e.class}: #{e.message}")
        false
      end
    end
  end
  