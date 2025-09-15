# frozen_string_literal: true

# Ejemplo de cómo usar reglas personalizadas

require_relative 'lib/validation/validator'
require_relative 'lib/validation/rules/custom_rules'

# Registrar reglas personalizadas
Validation::Rules::Registry.register(:no_scientific_notation, Validation::Rules::NoScientificNotation)
Validation::Rules::Registry.register(:category_code, Validation::Rules::CategoryCode)
Validation::Rules::Registry.register(:time_measurement, Validation::Rules::TimeMeasurement)

# Contract mejorado con reglas personalizadas
class ImprovedImportPricesContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {
      category_code: [:required, :category_code],
      rental_location_name: [:required, :string, [:min, 1]],
      rate_type_name: [:required, :string, [:min, 1]],
      season_name: [:nullable, :string],
      time_measurement: [:required, :time_measurement],
      units: [:required, :integer, [:min, 1]],
      price: [:required, :numeric, [:min, 0], :no_scientific_notation],
      included_km: [:nullable, :integer, [:min, 0]],
      extra_km_price: [:nullable, :numeric, [:min, 0], :no_scientific_notation]
    }
  end
end

# Ejemplo de uso con reglas personalizadas
def test_custom_validation
  puts "=== Probando reglas personalizadas ==="
  
  # Datos con notación científica (debería fallar)
  data_with_scientific = {
    'category_code' => 'A',
    'rental_location_name' => 'Barcelona',
    'rate_type_name' => 'Estándar',
    'season_name' => 'Alta',
    'time_measurement' => 'días',
    'units' => '2',
    'price' => '6e6.0',  # Notación científica - debería fallar
    'included_km' => '200',
    'extra_km_price' => '0.25'
  }

  contract = ImprovedImportPricesContract.new(data_with_scientific)
  validator = Validation::Validator.new(contract)
  
  begin
    validated = validator.validate!
    puts "✅ Validación exitosa!"
    puts "Datos validados: #{validated.inspect}"
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
  end

  puts "\n=== Probando código de categoría inválido ==="
  
  data_with_invalid_category = {
    'category_code' => '123',  # Debería empezar con letra
    'rental_location_name' => 'Barcelona',
    'rate_type_name' => 'Estándar',
    'season_name' => 'Alta',
    'time_measurement' => 'días',
    'units' => '2',
    'price' => '100.50',
    'included_km' => '200',
    'extra_km_price' => '0.25'
  }

  contract = ImprovedImportPricesContract.new(data_with_invalid_category)
  validator = Validation::Validator.new(contract)
  
  begin
    validated = validator.validate!
    puts "✅ Validación exitosa!"
    puts "Datos validados: #{validated.inspect}"
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
  end

  puts "\n=== Probando time_measurement inválido ==="
  
  data_with_invalid_time = {
    'category_code' => 'A',
    'rental_location_name' => 'Barcelona',
    'rate_type_name' => 'Estándar',
    'season_name' => 'Alta',
    'time_measurement' => 'semanas',  # No está en la lista permitida
    'units' => '2',
    'price' => '100.50',
    'included_km' => '200',
    'extra_km_price' => '0.25'
  }

  contract = ImprovedImportPricesContract.new(data_with_invalid_time)
  validator = Validation::Validator.new(contract)
  
  begin
    validated = validator.validate!
    puts "✅ Validación exitosa!"
    puts "Datos validados: #{validated.inspect}"
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
  end
end

# Ejecutar prueba
test_custom_validation