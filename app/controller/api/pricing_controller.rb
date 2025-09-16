require_relative '../../validation/validator'
require_relative '../../validation/contracts/pricing_contracts'

module Controller
  module Api
    module PricingController
      def self.registered(app)
        
        # REST API end-point to list price definitions with optional filters
        app.get '/api/open-pricing' do
          service = Service::PricingService.new
          validator = Validation::Validator.new(PricingContract.new({}))
          use_case = UseCase::Pricing::ListPricesUseCase.new(service, validator, logger)

          result = use_case.perform(params)

          if result.success?
            content_type :json
            result.data.to_json
          end
        end

        # REST API end-point to list price definitions with mandatory filters
        app.get '/api/pricing' do
          service = Service::PricingService.new
          validator = Validation::Validator.new(PricingFilterParamsContract.new({}))
          use_case = UseCase::Pricing::ListPricesUseCase.new(service, validator, logger)

          result = use_case.perform(params)

          if result.success?
            content_type :json
            result.data.to_json
          end
        end
      end
    end
  end
end