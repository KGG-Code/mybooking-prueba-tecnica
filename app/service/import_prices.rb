# frozen_string_literal: true
require "csv"
require_relative "import/import_result"

module Service
  class ImportPrices

    def initialize(csv_validator:, data_mapper:, entity_finder:, price_persister:, logger:)
      @csv_validator    = csv_validator
      @data_mapper      = data_mapper
      @entity_finder    = entity_finder
      @price_persister  = price_persister
      @logger           = logger
    end

    # Manejo de la interfaz, validaciones de entrada, logging de entrada
    def call(csv_path)
      run(csv_path)
    end

    # Lógica de negocio
    def run(csv_path) 
      info "Importando #{csv_path}…"
      processed_rows = 0
      skipped_rows = 0
      errors = []
      skipped_rows_details = []
      
      # Validar estructura del CSV
      # TODO: Pasar a fromato custom error
      unless @csv_validator.valid_structure?(csv_path)
        return Service::Import::ImportResult.new(
          success: false,
          message: "CSV file has invalid structure"
        )
      end
      
      CSV.foreach(csv_path, headers: true) do |row|
        begin
          # Normalizar datos de la fila
          normalized_data = @data_mapper.normalize_row(row)
          
          # Saltar filas completamente vacías
          if normalized_data.values.all? { |v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "Fila completamente vacía",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Validar fila individual
          unless @csv_validator.valid_row?(normalized_data)
            warn "Fila con datos inválidos: #{normalized_data.inspect}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "Datos inválidos en la fila",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Mapear time_measurement
          tm = @data_mapper.map_time_measurement(normalized_data[:time_measurement])
          unless tm
            warn "time_measurement desconocido: #{normalized_data[:time_measurement].inspect}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "time_measurement desconocido: #{normalized_data[:time_measurement]}",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Buscar entidades relacionadas
          category = @entity_finder.find_category(normalized_data[:category_code])
          rental_location = @entity_finder.find_rental_location(normalized_data[:rental_location_name])
          rate_type = @entity_finder.find_rate_type(normalized_data[:rate_type_name])
          
          unless category && rental_location && rate_type
            warn "No se resolvió category/location/rate_type: #{normalized_data.values_at(:category_code, :rental_location_name, :rate_type_name).inspect}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "No se encontró category/location/rate_type: #{normalized_data.values_at(:category_code, :rental_location_name, :rate_type_name).inspect}",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Buscar definición de precio
          pd_id, pd_sd_id = @entity_finder.find_price_definition_for(category.id, rental_location.id, rate_type.id)
          unless pd_id
            warn "No hay PriceDefinition vía CRLRT para #{category.code}/#{rental_location.name}/#{rate_type.name}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "No hay PriceDefinition para #{category.code}/#{rental_location.name}/#{rate_type.name}",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Buscar temporada
          season = @entity_finder.find_season_by_name(normalized_data[:season_name], pd_sd_id)
          unless season
            warn "Season '#{normalized_data[:season_name]}' no encontrado para PriceDefinition #{pd_id}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "Season '#{normalized_data[:season_name]}' no encontrado para PriceDefinition #{pd_id}",
              row_number: processed_rows + skipped_rows + 1
            }
            next
          end

          # Preparar datos para persistencia
          price_data = {
            price_definition_id: pd_id,
            season_id: season.id,
            time_measurement: tm,
            units: normalized_data[:units].to_i,
            price: @data_mapper.to_decimal_or_nil(normalized_data[:price]),
            included_km: @data_mapper.to_int_or_zero(normalized_data[:included_km]),
            extra_km_price: @data_mapper.to_decimal_or_zero(normalized_data[:extra_km_price]),
            category_code: category.code,
            rental_location_name: rental_location.name,
            rate_type_name: rate_type.name,
            season_name: season.name,
            time_measurement_text: normalized_data[:time_measurement]
          }

          # Persistir precio
          success, price_record = @price_persister.persist_price(price_data)
          
          if success
            processed_rows += 1
          else
            errors << "Error guardando precio para #{category.code}/#{rental_location.name}/#{rate_type.name}"
            skipped_rows += 1
            skipped_rows_details << {
              row_data: normalized_data,
              reason: "Error al guardar en base de datos",
              row_number: processed_rows + skipped_rows + 1,
              price_data: price_data
            }
          end
          
        rescue => e
          warn "EXCEPCIÓN procesando fila: #{normalized_data.inspect rescue 'datos no disponibles'} | Error: #{e.message}"
          errors << "Error procesando fila: #{e.message}"
          skipped_rows += 1
          skipped_rows_details << {
            row_data: (normalized_data.inspect rescue 'datos no disponibles'),
            reason: "Excepción: #{e.message}",
            row_number: processed_rows + skipped_rows + 1,
            exception: e.class.name
          }
        end
      end
      
      info "Importación finalizada. Procesadas: #{processed_rows}, Omitidas: #{skipped_rows}"
      
      Service::Import::ImportResult.new(
        success: true,
        processed_rows: processed_rows,
        skipped_rows: skipped_rows,
        errors: errors,
        message: "Importación completada",
        skipped_rows_details: skipped_rows_details
      )
    end

    private

    def info(msg) = @logger.info("[INFO] #{msg}")
    def warn(msg) = @logger.warn("[WARN] #{msg}")
  end
end
