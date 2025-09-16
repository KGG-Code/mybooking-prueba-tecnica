# frozen_string_literal: true

module Validation
  module Rules
    # Regla personalizada para validar que el precio no tenga notación científica
    class NoScientificNotation < BaseRule
      def self.validate(value, options = {})
        str_value = value.to_s.strip.tr(',', '.')
        
        # Regex para números decimales normales (sin notación científica)
        if /\A-?\d+(\.\d+)?\z/.match?(str_value)
          success_message(value)
        else
          error_message("no debe usar notación científica")
        end
      end
    end

    # Regla personalizada para validar códigos de categoría
    class CategoryCode < BaseRule
      def self.validate(value, options = {})
        str_value = value.to_s.strip.upcase
        
        # Debe ser una letra seguida opcionalmente de números
        if /\A[A-Z]\d*\z/.match?(str_value)
          success_message(str_value)
        else
          error_message("debe ser una letra seguida opcionalmente de números (ej: A, B1, C123)")
        end
      end
    end

    # Regla personalizada para validar unidades de tiempo
    class TimeMeasurement < BaseRule
      ALLOWED_VALUES = ['días', 'meses', 'horas', 'minutos', '1', '2', '3', '4'].freeze

      def self.validate(value, options = {})
        str_value = value.to_s.strip.downcase
        
        if ALLOWED_VALUES.include?(str_value)
          success_message(str_value)
        else
          error_message("debe ser uno de: #{ALLOWED_VALUES.join(', ')}")
        end
      end
    end
  end
end