# frozen_string_literal: true

# Ejemplo de uso de los contracts de pricing con el nuevo sistema

require_relative 'lib/validation/validator'
require_relative 'app/validation/contracts/pricing_contracts'

# Ejemplo 1: Validar parámetros de filtrado (como en pricing_controller)
def test_pricing_filter_contract
  puts "=== Probando PricingFilterParamsContract ==="
  
  # Parámetros válidos de filtrado
  filter_params = {
    'rental_location_id' => '1',
    'rate_type_id' => '2',
    'season_definition_id' => '3',
    'season_id' => '5',
    'unit' => '2',
    'per_page' => '25'
  }

  contract = PricingFilterParamsContract.new(filter_params)
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

# Ejemplo 2: Validar datos de importación CSV
def test_import_csv_contract
  puts "\n=== Probando ImportPricesCsvContract ==="
  
  # Datos válidos de importación CSV
  csv_data = {
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

  contract = ImportPricesCsvContract.new(csv_data)
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

# Ejemplo 3: Contract combinado (filtrado + importación)
def test_combined_contract
  puts "\n=== Probando PricingFilterContract (combinado) ==="
  
  # Datos que incluyen tanto filtros como datos de importación
  combined_data = {
    # Parámetros de filtrado
    'rental_location_id' => '1',
    'rate_type_id' => '2',
    'season_definition_id' => '3',
    'season_id' => '5',
    'unit' => '2',
    'per_page' => '25',
    
    # Datos de importación
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

  contract = PricingFilterContract.new(combined_data)
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

# Ejecutar ejemplos
test_pricing_filter_contract
test_import_csv_contract
test_combined_contract

puts "\n=== Resumen de Contracts ==="
puts "1. PricingFilterParamsContract - Solo parámetros de filtrado"
puts "2. ImportPricesCsvContract - Solo datos de importación CSV"
puts "3. PricingFilterContract - Combinado (filtrado + importación)"