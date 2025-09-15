require_relative '../../validation/validator'
require_relative '../../validation/contracts/pricing_contracts'

module Controller
  module Api
    module PricingController
      def self.registered(app)
        
          # REST API end-point to list price definitions with optional filters
          app.get '/api/open-pricing' do
            begin
              service = Service::PricingService.new
              validator = Validation::Validator.new(PricingContract.new({}))
              use_case = UseCase::Pricing::ListPricesUseCase.new(service, validator, logger)

              result = use_case.perform(params)

              if result.success?
                content_type :json
                result.data.to_json
              else
                status 422
                { errors: result.errors }.to_json
              end
            rescue => e
              STDERR.puts "🔍 CONTROLLER ERROR: #{e.class}: #{e.message}"
              status 500
              { error: "Error interno del servidor" }.to_json
            end
          end

          # REST API end-point to list price definitions with mandatory filters
          app.get '/api/pricing' do
            begin
              service = Service::PricingService.new
              validator = Validation::Validator.new(PricingFilterParamsContract.new({}))
              use_case = UseCase::Pricing::ListPricesUseCase.new(service, validator, logger)

              result = use_case.perform(params)

            if result.success?
              content_type :json
              result.data.to_json
            else
              status 422
              { errors: result.errors }.to_json
            end
          rescue => e
            STDERR.puts "🔍 CONTROLLER ERROR: #{e.class}: #{e.message}"
            status 500
            { error: "Error interno del servidor" }.to_json
          end
        end

#        # REST API end-point to get units list as string
#        app.get '/api/units-list' do
#          service = Service::PricingService.new
#          validator = Validation::Validator.new({})
#          
#          validator.set_schema({
#            rental_location_id: [:optional, :int],
#            rate_type_id: [:optional, :int],
#            season_definition_id: [:optional, :nullable, :int],
#            season_id: [:optional, :nullable, :int],
#            unit: [:optional, [:enum, *TimeUnitConstants::VALID_TIME_UNITS]]
#          })
#          validator.validate!(params)
#          
#          conditions = {}
#          conditions[:rental_location_id] = validator.data[:rental_location_id] if validator.data[:rental_location_id]
#          conditions[:rate_type_id] = validator.data[:rate_type_id] if validator.data[:rate_type_id]
#          conditions[:season_definition_id] = validator.data[:season_definition_id] if validator.data[:season_definition_id]
#          conditions[:season_id] = validator.data[:season_id] if validator.data[:season_id]
#          conditions[:unit] = validator.data[:unit] if validator.data[:unit]
#          
#          units_string = service.get_units_list_by_filters(conditions)
#          
#          content_type :json
#          { units: units_string }.to_json
#        end

      end
    end
  end
end