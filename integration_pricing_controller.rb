# frozen_string_literal: true

# Ejemplo de cómo integrar PricingFilterContract en pricing_controller.rb

require_relative 'lib/validation/validator'
require_relative 'app/validation/contracts/pricing_contracts'

# Versión mejorada del pricing_controller.rb con validación
module Controller
  module Api
    module ImprovedPricingController
      def self.registered(app)
        
        app.get '/api/filtered-pricing' do
          content_type 'application/json; charset=utf-8'
          
          # Extraer parámetros de la query string
          params_to_validate = {
            'rental_location_id' => params[:rental_location_id],
            'rate_type_id' => params[:rate_type_id],
            'season_definition_id' => params[:season_definition_id],
            'season_id' => params[:season_id],
            'unit' => params[:unit],
            'per_page' => params[:per_page]
          }
          
          # Validar parámetros usando el contract
          contract = PricingFilterParamsContract.new(params_to_validate)
          validator = Validation::Validator.new(contract)
          
          begin
            # Validar parámetros
            validated_params = validator.validate!
            
            # Usar parámetros validados para la consulta
            results = get_filtered_prices(validated_params)
            
            status 200
            results.to_json
            
          rescue Validation::Error => e
            # Devolver errores de validación
            status 422
            {
              success: false,
              message: "Parámetros de filtrado inválidos",
              errors: e.errors
            }.to_json
          rescue => e
            logger&.error "[ImprovedPricingController] #{e.class}: #{e.message}"
            halt 500, { error: 'Error interno del servidor' }.to_json
          end
        end

        app.get '/api/units-list' do
          content_type 'application/json; charset=utf-8'
          
          # Validar parámetros para units-list también
          params_to_validate = {
            'rental_location_id' => params[:rental_location_id],
            'rate_type_id' => params[:rate_type_id],
            'season_definition_id' => params[:season_definition_id],
            'season_id' => params[:season_id],
            'unit' => params[:unit]
          }
          
          contract = PricingFilterParamsContract.new(params_to_validate)
          validator = Validation::Validator.new(contract)
          
          begin
            validated_params = validator.validate!
            units = get_available_units(validated_params)
            
            status 200
            { units: units.join(',') }.to_json
            
          rescue Validation::Error => e
            status 422
            {
              success: false,
              message: "Parámetros inválidos",
              errors: e.errors
            }.to_json
          end
        end
      end

      private

      def self.get_filtered_prices(validated_params)
        # Aquí usarías tu servicio existente con los parámetros validados
        # Por ejemplo:
        
        # service = PricingService.new
        # service.get_price_definitions(
        #   rental_location_id: validated_params[:rental_location_id],
        #   rate_type_id: validated_params[:rate_type_id],
        #   season_definition_id: validated_params[:season_definition_id],
        #   season_id: validated_params[:season_id],
        #   unit: validated_params[:unit],
        #   per_page: validated_params[:per_page]
        # )
        
        # Por ahora, simular respuesta
        {
          success: true,
          data: [
            {
              category_code: 'A',
              prices: [
                { units: 1, price: 100.50 },
                { units: 3, price: 250.75 }
              ]
            }
          ],
          total: 1,
          per_page: validated_params[:per_page] || 25
        }
      end

      def self.get_available_units(validated_params)
        # Simular obtención de unidades disponibles
        [1, 3, 7, 15]
      end
    end
  end
end

# Ejemplo de uso en Sinatra
puts "=== Ejemplo de integración en Sinatra ==="

# Simular parámetros de request
def simulate_request(params)
  puts "Simulando request con parámetros: #{params}"
  
  # Simular validación
  contract = PricingFilterParamsContract.new(params)
  validator = Validation::Validator.new(contract)
  
  begin
    validated_params = validator.validate!
    puts "✅ Parámetros válidos: #{validated_params}"
    
    # Simular respuesta exitosa
    {
      success: true,
      data: "Datos de precios filtrados",
      validated_params: validated_params
    }
  rescue Validation::Error => e
    puts "❌ Errores de validación:"
    e.errors.each { |field, messages| puts "  #{field}: #{messages.join(', ')}" }
    
    {
      success: false,
      errors: e.errors,
      message: "Parámetros inválidos"
    }
  end
end

# Probar con diferentes casos
puts "\n--- Caso 1: Parámetros válidos ---"
valid_params = {
  'rental_location_id' => '1',
  'rate_type_id' => '2',
  'season_definition_id' => '3',
  'season_id' => '5',
  'unit' => '2',
  'per_page' => '25'
}
result1 = simulate_request(valid_params)

puts "\n--- Caso 2: Parámetros inválidos ---"
invalid_params = {
  'rental_location_id' => 'abc',  # Debería ser entero
  'rate_type_id' => '2',
  'unit' => '10',  # No está en [1,2,3,4]
  'per_page' => 'invalid'  # Debería ser entero
}
result2 = simulate_request(invalid_params)

puts "\n--- Caso 3: Parámetros opcionales ---"
optional_params = {
  'rental_location_id' => '1',
  'rate_type_id' => '2'
  # Los demás son opcionales
}
result3 = simulate_request(optional_params)

puts "\n--- Caso 4: Con valores null ---"
null_params = {
  'rental_location_id' => '1',
  'rate_type_id' => '2',
  'season_definition_id' => nil,  # Nullable
  'season_id' => nil,  # Nullable
  'unit' => '2'
}
result4 = simulate_request(null_params)