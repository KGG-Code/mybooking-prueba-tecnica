# frozen_string_literal: true

module Validation
  module Rules
    class Registry
      @rules = {}

      def self.register(name, rule_class)
        @rules[name.to_sym] = rule_class
      end

      def self.get(name)
        @rules[name.to_sym]
      end

      def self.all
        @rules
      end

      # Registrar reglas por defecto
      def self.register_defaults
        register(:required, Required)
        register(:string, String)
        register(:integer, Integer)
        register(:int, Int)  # Alias para integer
        register(:numeric, Numeric)
        register(:email, Email)
        register(:min, Min)
        register(:max, Max)
        register(:in, In)
        register(:regex, Regex)
        register(:optional, Optional)
        register(:nullable, Nullable)
        register(:enum, Enum)
        
        # Reglas personalizadas
        register(:no_scientific_notation, NoScientificNotation)
        register(:category_code, CategoryCode)
        register(:time_measurement, TimeMeasurement)
      end

      # Cargar todas las reglas automáticamente
      def self.load_rules
        rules_dir = File.join(__dir__, 'rules')
        Dir.glob(File.join(rules_dir, '*.rb')).each do |file|
          require file
        end
        register_defaults
      end
    end
  end
end