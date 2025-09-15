# frozen_string_literal: true

module UseCase
  module Import
    class ImportPricesUseCase
      Result = Struct.new(:success?, :message, :imported, :total, :errors, keyword_init: true)

      def initialize(reader:, importer:, validator:, logger: nil)
        @reader    = reader      # each { |row| ... } con row._row_number
        @importer  = importer    # Service::ImportPrices
        @validator = validator
        @logger    = logger
      end

      def perform
        safe_validate!

        imported = 0
        total    = 0
        errors   = []

        @reader.each do |row|
          total += 1
          status, reason = @importer.import(row) # [:ok, nil] o [:error, "reason"]
          
          if status == :ok
            imported += 1
          else
            errors << {
              row:    (row.respond_to?(:_row_number) ? row._row_number : total),
              values: {
                category_code:        safe_str(row, :category_code),
                rental_location_name: safe_str(row, :rental_location_name),
                rate_type_name:       safe_str(row, :rate_type_name),
                season_name:          safe_str(row, :season_name),
                time_measurement:     safe_str(row, :time_measurement),
                units:                safe_str(row, :units),
                price:                safe_str(row, :price),
                included_km:          safe_str(row, :included_km),
                extra_km_price:       safe_str(row, :extra_km_price)
              },
              reason: reason.to_s
            }
          end
        end

        msg = errors.empty? ? "Importadas #{imported}/#{total} filas" :
                              "Importadas #{imported}/#{total} filas; #{errors.size} con errores"

        Result.new(success?: errors.empty?, message: msg, imported: imported, total: total, errors: errors)
      rescue Validation::Error => e
        @logger&.warn("[ImportPricesUseCase] validation failed: #{e.message}")
        Result.new(success?: false, message: e.message, imported: 0, total: 0, errors: [])
      rescue => e
        @logger&.error("[ImportPricesUseCase] unexpected: #{e.class}: #{e.message}")
        Result.new(success?: false, message: 'Fallo inesperado en la importación', imported: 0, total: 0, errors: [])
      end

      private

      def safe_validate!
        return unless @validator.respond_to?(:validate!)
        arity = @validator.method(:validate!).arity
        arity == 0 ? @validator.validate! : @validator.validate!({})
      end

      def safe_str(row, attr)
        row.respond_to?(attr) ? row.public_send(attr) : nil
      end
    end
  end
end
