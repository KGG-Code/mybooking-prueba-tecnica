# frozen_string_literal: true

# Ejemplos prácticos de cómo aplicar PricingFilterContract

require_relative 'app/validation/validator'
require_relative 'app/validation/contracts/pricing_contracts'

# Ejemplo 1: En un controlador de API (como pricing_controller.rb)
class PricingControllerExample
  def self.filter_prices(params)
    puts "=== Ejemplo 1: En controlador de API ==="
    
    # Crear contract con los parámetros recibidos
    contract = PricingFilterParamsContract.new(params)
    validator = Validation::Validator.new(contract)
    
    begin
      # Validar parámetros
      validated_params = validator.validate!
      
      puts "✅ Parámetros válidos:"
      puts "  rental_location_id: #{validated_params[:rental_location_id]}"
      puts "  rate_type_id: #{validated_params[:rate_type_id]}"
      puts "  season_definition_id: #{validated_params[:season_definition_id]}"
      puts "  season_id: #{validated_params[:season_id]}"
      puts "  unit: #{validated_params[:unit]}"
      puts "  per_page: #{validated_params[:per_page]}"
      
      # Aquí harías la llamada a tu servicio
      # service = PricingService.new
      # results = service.get_filtered_prices(validated_params)
      
      return { success: true, data: validated_params }
      
    rescue Validation::Error => e
      puts "❌ Errores de validación:"
      e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
      
      return { 
        success: false, 
        errors: e.errors,
        message: "Parámetros de filtrado inválidos"
      }
    end
  end
end

# Ejemplo 2: En un Use Case
class FilterPricesUseCase
  def initialize(validator: nil)
    @validator = validator || Validation::Validator
  end

  def perform(params)
    puts "\n=== Ejemplo 2: En Use Case ==="
    
    # Crear contract
    contract = PricingFilterParamsContract.new(params)
    validator = @validator.new(contract)
    
    # Validar sin excepción
    result = validator.validate
    
    unless result.success?
      puts "❌ Validación falló:"
      result.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
      return { success: false, errors: result.errors }
    end
    
    puts "✅ Parámetros validados correctamente"
    
    # Procesar con parámetros validados
    filtered_data = process_filtered_params(result.validated)
    
    { success: true, data: filtered_data }
  end

  private

  def process_filtered_params(params)
    # Simular procesamiento
    {
      rental_location_id: params[:rental_location_id],
      rate_type_id: params[:rate_type_id],
      season_definition_id: params[:season_definition_id],
      season_id: params[:season_id],
      unit: params[:unit],
      per_page: params[:per_page] || 25
    }
  end
end

# Ejemplo 3: En un servicio
class PricingService
  def initialize(validator: nil)
    @validator = validator || Validation::Validator
  end

  def get_filtered_prices(params)
    puts "\n=== Ejemplo 3: En Servicio ==="
    
    # Validar parámetros de entrada
    contract = PricingFilterParamsContract.new(params)
    validator = @validator.new(contract)
    
    validation_result = validator.validate
    
    if validation_result.success?
      puts "✅ Parámetros válidos, procesando..."
      
      # Construir query con parámetros validados
      query_params = build_query_params(validation_result.validated)
      
      # Simular llamada a base de datos
      results = simulate_database_query(query_params)
      
      { success: true, data: results }
    else
      puts "❌ Parámetros inválidos:"
      validation_result.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
      
      { success: false, errors: validation_result.errors }
    end
  end

  private

  def build_query_params(validated_params)
    query = {}
    
    query[:rental_location_id] = validated_params[:rental_location_id] if validated_params[:rental_location_id]
    query[:rate_type_id] = validated_params[:rate_type_id] if validated_params[:rate_type_id]
    query[:season_definition_id] = validated_params[:season_definition_id] if validated_params[:season_definition_id]
    query[:season_id] = validated_params[:season_id] if validated_params[:season_id]
    query[:unit] = validated_params[:unit] if validated_params[:unit]
    query[:per_page] = validated_params[:per_page] || 25
    
    query
  end

  def simulate_database_query(params)
    # Simular resultados de base de datos
    {
      total: 150,
      per_page: params[:per_page],
      current_page: 1,
      prices: [
        { id: 1, category: 'A', price: 100.50 },
        { id: 2, category: 'B', price: 200.75 }
      ]
    }
  end
end

# Ejemplo 4: En middleware de validación
class ValidationMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    if request.path == '/api/filtered-pricing'
      puts "\n=== Ejemplo 4: En Middleware ==="
      
      # Extraer parámetros de la query string
      params = request.params
      
      # Validar parámetros
      contract = PricingFilterParamsContract.new(params)
      validator = Validation::Validator.new(contract)
      
      validation_result = validator.validate
      
      if validation_result.success?
        puts "✅ Middleware: Parámetros válidos, continuando..."
        
        # Agregar parámetros validados al env para que los use el controlador
        env['validated_params'] = validation_result.validated
        
        # Continuar con la aplicación
        @app.call(env)
      else
        puts "❌ Middleware: Parámetros inválidos, rechazando request"
        
        # Devolver error de validación
        [
          422,
          { 'Content-Type' => 'application/json' },
          [{ 
            success: false, 
            errors: validation_result.errors,
            message: "Parámetros de filtrado inválidos"
          }.to_json]
        ]
      end
    else
      @app.call(env)
    end
  end
end

# Ejecutar ejemplos
def run_examples
  # Datos de ejemplo
  valid_params = {
    'rental_location_id' => '1',
    'rate_type_id' => '2',
    'season_definition_id' => '3',
    'season_id' => '5',
    'unit' => '2',
    'per_page' => '25'
  }

  invalid_params = {
    'rental_location_id' => 'abc',  # Debería ser entero
    'rate_type_id' => '2',
    'season_definition_id' => '3',
    'season_id' => '5',
    'unit' => '10',  # No está en [1,2,3,4]
    'per_page' => 'invalid'  # Debería ser entero
  }

  # Ejemplo 1: Controlador
  PricingControllerExample.filter_prices(valid_params)
  PricingControllerExample.filter_prices(invalid_params)

  # Ejemplo 2: Use Case
  use_case = FilterPricesUseCase.new
  use_case.perform(valid_params)
  use_case.perform(invalid_params)

  # Ejemplo 3: Servicio
  service = PricingService.new
  service.get_filtered_prices(valid_params)
  service.get_filtered_prices(invalid_params)

  # Ejemplo 4: Middleware (simulado)
  puts "\n=== Ejemplo 4: Middleware (simulado) ==="
  middleware = ValidationMiddleware.new(->(env) { [200, {}, ['OK']] })
  
  # Simular request válido
  env_valid = {
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => '/api/filtered-pricing',
    'QUERY_STRING' => 'rental_location_id=1&rate_type_id=2&unit=2'
  }
  middleware.call(env_valid)
  
  # Simular request inválido
  env_invalid = {
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => '/api/filtered-pricing',
    'QUERY_STRING' => 'rental_location_id=abc&unit=10'
  }
  middleware.call(env_invalid)
end

# Ejecutar todos los ejemplos
run_examples