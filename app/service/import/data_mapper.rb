module Service
  module Import
    #
    # Servicio especializado en mapeo y normalización de datos CSV
    #
    class DataMapper
      TIME_MEAS_MAP = {
        "dias"    => 2, "días"    => 2, "day"     => 2, "days"    => 2,
        "horas"   => 3, "hora"    => 3, "hours"   => 3, "hour"    => 3,
        "minutos" => 4, "minuto"  => 4, "mins"    => 4, "minutes" => 4,
        "meses"   => 1, "mes"     => 1, "months"  => 1, "month"   => 1
      }.freeze

      def initialize(logger:)
        @logger = logger
      end

      #
      # Normaliza una fila del CSV
      #
      # @param [CSV::Row] row - Fila del CSV
      # @return [Hash] Datos normalizados
      #
      def normalize_row(row)
        row.to_h.each_with_object({}) do |(k, v), h|
          h[k.to_s.strip.downcase.gsub(/\s+/, "_").to_sym] = v.is_a?(String) ? v.strip : v
        end
      end

      #
      # Mapea time_measurement de texto a entero
      #
      # @param [String] text - Valor de texto
      # @return [Integer, nil] Valor entero o nil si no es válido
      #
      def map_time_measurement(text)
        TIME_MEAS_MAP[text.to_s.downcase]
      end

      #
      # Convierte string a BigDecimal o nil
      #
      # @param [String] value - Valor a convertir
      # @return [BigDecimal, nil] Valor convertido o nil si está vacío
      #
      def to_decimal_or_nil(value)
        value = value.to_s.strip
        return nil if value.empty?
        BigDecimal(value)
      rescue ArgumentError
        nil
      end

      #
      # Convierte string a BigDecimal o cero
      #
      # @param [String] value - Valor a convertir
      # @return [BigDecimal] Valor convertido o cero si está vacío
      #
      def to_decimal_or_zero(value)
        value = value.to_s.strip
        return BigDecimal('0') if value.empty?
        BigDecimal(value)
      rescue ArgumentError
        BigDecimal('0')
      end

      #
      # Convierte string a Integer o cero
      #
      # @param [String] value - Valor a convertir
      # @return [Integer] Valor convertido o cero si está vacío
      #
      def to_int_or_zero(value)
        value = value.to_s.strip
        return 0 if value.empty?
        Integer(value)
      rescue ArgumentError
        0
      end
    end
  end
end