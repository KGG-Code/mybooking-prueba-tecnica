module Service
  module Import
    #
    # Servicio especializado en persistencia de precios
    #
    class PricePersister
      def initialize(price_repository, logger:)
        @price_repository = price_repository
        @logger = logger
      end

      #
      # Persiste o actualiza un precio
      #
      # @param [Hash] price_data - Datos del precio a persistir
      # @return [Array] [success, price_record] - Éxito y registro del precio
      #
      def persist_price(price_data)
        # Buscar precio existente o crear uno nuevo
        price_record = @price_repository.first(
          price_definition_id: price_data[:price_definition_id],
          season_id: price_data[:season_id],
          time_measurement: price_data[:time_measurement],
          units: price_data[:units]
        ) || @price_repository.model_class.new(
          price_definition_id: price_data[:price_definition_id],
          season_id: price_data[:season_id],
          time_measurement: price_data[:time_measurement],
          units: price_data[:units]
        )

        # Asignar valores
        price_record.price = price_data[:price]
        price_record.included_km = price_data[:included_km]
        price_record.extra_km_price = price_data[:extra_km_price]

        # Log de valores que se intentan guardar
        @logger.info "Intentando guardar: price_definition_id=#{price_record.price_definition_id}, season_id=#{price_record.season_id}, time_measurement=#{price_record.time_measurement}, units=#{price_record.units}, price=#{price_record.price}, included_km=#{price_record.included_km}, extra_km_price=#{price_record.extra_km_price}"

        # Intentar guardar
        if price_record.save
          @logger.info "OK #{price_data[:category_code]}/#{price_data[:rental_location_name]}/#{price_data[:rate_type_name]} | #{price_data[:season_name]} #{price_data[:units]} #{price_data[:time_measurement_text]} => #{price_record.price}"
          [true, price_record]
        else
          error_details = price_record.errors.full_messages.join(", ")
          @logger.warn "ERROR al guardar: #{price_data[:category_code]}/#{price_data[:rental_location_name]}/#{price_data[:rate_type_name]} | #{price_data[:season_name]} #{price_data[:units]} #{price_data[:time_measurement_text]} => #{price_record.price} | Valores: price_definition_id=#{price_record.price_definition_id}, season_id=#{price_record.season_id}, time_measurement=#{price_record.time_measurement}, units=#{price_record.units}, price=#{price_record.price}, included_km=#{price_record.included_km}, extra_km_price=#{price_record.extra_km_price} | Errores: #{error_details}"
          [false, price_record]
        end
      end
    end
  end
end