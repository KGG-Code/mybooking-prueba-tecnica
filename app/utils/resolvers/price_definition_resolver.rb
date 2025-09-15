# frozen_string_literal: true

module Utils
  module Resolvers
    # Resuelve price_definition_id a partir de:
    #   category_code, rental_location_name, rate_type_name
    class PriceDefinitionResolver
    def initialize(category_repo:, rental_location_repo:, rate_type_repo:, crlrt_repo:, logger: nil)
      @categories = category_repo
      @rlocs      = rental_location_repo
      @rates      = rate_type_repo
      @crlrt      = crlrt_repo
      @logger     = logger
    end

    def call(row)
      category_code = row.category_code
      rental_location_name = row.rental_location_name
      rate_type_name = row.rate_type_name
      
      return nil if blank?(category_code) || blank?(rental_location_name) || blank?(rate_type_name)

      category = @categories.first(code: category_code)
      rloc     = @rlocs.first(name: rental_location_name)
      rate     = @rates.first(name: rate_type_name)

      unless category && rloc && rate
        @logger&.warn("[PriceDefinitionResolver] No se hallaron IDs: cat=#{!!category} rl=#{!!rloc} rt=#{!!rate}")
        return nil
      end

      # Fila puente: category_rental_location_rate_types
      link = @crlrt.first(category_id: category.id, rental_location_id: rloc.id, rate_type_id: rate.id)
      unless link && link.respond_to?(:price_definition_id)
        @logger&.warn("[PriceDefinitionResolver] CRLRT no encontrada para cat=#{category.id}, rl=#{rloc.id}, rt=#{rate.id}")
        return nil
      end

      link.price_definition_id
    rescue => e
      @logger&.error("[PriceDefinitionResolver] #{e.class}: #{e.message}")
      nil
    end

    private

    def blank?(v) = v.nil? || v.to_s.strip.empty?
    end
  end
end