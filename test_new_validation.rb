# frozen_string_literal: true

# Ejemplo de uso del nuevo sistema de validación con reglas separadas

require_relative 'lib/validation/validator'

# Contract para importación de precios CSV
class ImportPricesContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {
      category_code: [:required, :string, [:min, 1]],
      rental_location_name: [:required, :string, [:min, 1]],
      rate_type_name: [:required, :string, [:min, 1]],
      season_name: [:nullable, :string],
      time_measurement: [:required, :string, [:in, ['días', 'meses', 'horas', 'minutos', '1', '2', '3', '4']]],
      units: [:required, :integer, [:min, 1]],
      price: [:required, :numeric, [:min, 0]],
      included_km: [:nullable, :integer, [:min, 0]],
      extra_km_price: [:nullable, :numeric, [:min, 0]]
    }
  end
end

# Ejemplo de uso
def test_validation
  # Datos válidos
  valid_data = {
    'category_code' => 'A',
    'rental_location_name' => 'Barcelona',
    'rate_type_name' => 'Estándar',
    'season_name' => 'Alta',
    'time_measurement' => 'días',
    'units' => '2',
    'price' => '100.50',
    'included_km' => '200',
    'extra_km_price' => '0.25'
  }

  # Datos con errores
  invalid_data = {
    'category_code' => '',
    'rental_location_name' => 'Barcelona',
    'rate_type_name' => 'Estándar',
    'season_name' => 'Alta',
    'time_measurement' => 'invalid',
    'units' => 'abc',
    'price' => '-10',
    'included_km' => '-5',
    'extra_km_price' => 'invalid'
  }

  puts "=== Probando datos válidos ==="
  contract = ImportPricesContract.new(valid_data)
  validator = Validation::Validator.new(contract)
  
  begin
    validated = validator.validate!
    puts "✅ Validación exitosa!"
    puts "Datos validados: #{validated.inspect}"
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
  end

  puts "\n=== Probando datos inválidos ==="
  contract = ImportPricesContract.new(invalid_data)
  validator = Validation::Validator.new(contract)
  
  begin
    validated = validator.validate!
    puts "✅ Validación exitosa!"
    puts "Datos validados: #{validated.inspect}"
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
  end

  puts "\n=== Probando método validate (sin excepción) ==="
  result = validator.validate
  puts "Éxito: #{result.success?}"
  puts "Errores: #{result.errors}"
  puts "Validados: #{result.validated}"
end

# Ejecutar prueba
test_validation