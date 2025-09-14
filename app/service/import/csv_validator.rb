module Service
  module Import
    #
    # Servicio especializado en validación de archivos CSV
    #
    class CsvValidator
      REQUIRED_HEADERS = ["category_code", "rental_location_name", "rate_type_name", "season_name", "time_measurement", "units"].freeze
      OPTIONAL_HEADERS = ["price", "included_km", "extra_km_price"].freeze

      def initialize(logger:)
        @logger = logger
      end

      #
      # Valida que el archivo CSV tenga la estructura correcta
      #
      # @param [String] csv_path - Ruta al archivo CSV
      # @return [Boolean] true si es válido, false en caso contrario
      #
      def valid_structure?(csv_path)
        return false unless File.exist?(csv_path)
        return false unless File.size(csv_path) > 0

        begin
          CSV.foreach(csv_path, headers: true) do |row|
            missing_headers = REQUIRED_HEADERS - row.headers.map(&:downcase)
            
            if missing_headers.any?
              @logger.error "CsvValidator - Missing required headers: #{missing_headers.join(', ')}"
              return false
            end
            
            break
          end
          
          true
        rescue CSV::MalformedCSVError => e
          @logger.error "CsvValidator - Malformed CSV: #{e.message}"
          false
        rescue => e
          @logger.error "CsvValidator - Error reading CSV: #{e.message}"
          false
        end
      end

      #
      # Valida una fila individual del CSV
      #
      # @param [Hash] row_data - Datos de la fila normalizados
      # @return [Boolean] true si es válida, false en caso contrario
      #
      def valid_row?(row_data)
        # Verificar campos requeridos
        required_fields = [:category_code, :rental_location_name, :rate_type_name, :season_name, :time_measurement, :units]
        return false unless required_fields.all? { |field| present?(row_data[field]) }

        # Verificar time_measurement válido
        return false unless valid_time_measurement?(row_data[:time_measurement])

        # Verificar units es numérico
        return false unless numeric?(row_data[:units])

        true
      end

      private

      def present?(value)
        !(value.nil? || (value.respond_to?(:empty?) && value.empty?))
      end

      def numeric?(value)
        value.to_s.match?(/^\d+$/)
      end

      def valid_time_measurement?(value)
        ["dias", "días", "day", "days", "horas", "hora", "hours", "hour", "minutos", "minuto", "mins", "minutes", "meses", "mes", "months", "month"].include?(value.to_s.downcase)
      end
    end
  end
end