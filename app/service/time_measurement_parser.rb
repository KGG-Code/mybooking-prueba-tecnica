# frozen_string_literal: true

module Service
  # "2" -> 2, "días" / "dias" -> 2, "horas" -> 3, etc. Robusto sin requires.
  class TimeMeasurementParser
    RAW = {
      'mes' => 1, 'meses' => 1,
      'día' => 2, 'dias' => 2, 'día(s)' => 2, 'días' => 2,
      'hora' => 3, 'horas' => 3,
      'minuto' => 4, 'minutos' => 4
    }.freeze

    # Métodos de clase para construir las tablas estáticas
    def self.normalize_nfc_static(str)
      s = str.to_s
      # Forzar codificación UTF-8 si es necesario
      s = s.force_encoding('UTF-8') if s.encoding == Encoding::ASCII_8BIT
      s = s.respond_to?(:unicode_normalize) ? s.unicode_normalize(:nfc) : s
      s = s.downcase
      s.tr("\u00A0", ' ').strip
    end

    # Elimina diacríticos si hay unicode_normalize(:nfkd); si no, fallback manual
    def self.strip_diacritics_static(str)
      s = str.to_s
      # Forzar codificación UTF-8 si es necesario
      s = s.force_encoding('UTF-8') if s.encoding == Encoding::ASCII_8BIT
      if s.respond_to?(:unicode_normalize)
        s = s.unicode_normalize(:nfkd).gsub(/\p{Mn}/, '')
      else
        # Fallback manual para caracteres más comunes en ES
        s = s.tr(
          'áàäâÁÀÄÂéèëêÉÈËÊíìïîÍÌÏÎóòöôÓÒÖÔúùüûÚÙÜÛñÑçÇ',
          'aaaaAAAAeeeeEEEEiiiiIIIIooooOOOOuuuuUUUUnNcC'
        )
      end
      s
    end

    # Tablas preparadas con y sin diacríticos (en minúscula)
    NFC_MAP   = RAW.transform_keys { |k| normalize_nfc_static(k) }.freeze
    ASCII_MAP = NFC_MAP.each_with_object({}) { |(k, v), h| h[strip_diacritics_static(k)] = v }.freeze

    def call(value)
      return nil if value.nil?

      s = value.to_s.strip
      return nil if s.empty?

      # numérico directo
      return s.to_i if /\A-?\d+\z/ === s

      token = normalize_nfc(s)

      # lookup con acentos
      val = NFC_MAP[token]
      return val unless val.nil?

      # lookup sin acentos
      ASCII_MAP[strip_diacritics(token)]
    end

    private

    # ==== Normalización segura sin dependencias externas ====

    # Normaliza a NFC si String#unicode_normalize existe; si no, baja a minúsculas,
    # sustituye NBSP y recorta.
    def normalize_nfc(str)
      self.class.normalize_nfc_static(str)
    end

    def strip_diacritics(str)
      self.class.strip_diacritics_static(str)
    end
  end
end