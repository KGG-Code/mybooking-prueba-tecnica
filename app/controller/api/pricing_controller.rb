module Controller
  module Api
    module PricingController
      def self.registered(app)
        # REST API end-point to list price definitions with optional filters
        app.get '/api/pricing' do
          service = Service::PricingService.new
          use_case = UseCase::Pricing::ListPriceDefinitionsUseCase.new(service, logger)

          result = use_case.perform(params)

          if result.success?
            content_type :json
            result.data.to_json
          end
        end

        # REST API end-point to list price definitions with mandatory filters
        app.get '/api/filtered-pricing' do
          service = Service::PricingService.new
          use_case = UseCase::Pricing::ListPriceDefinitionsBySeasonDefinitionUseCase.new(
            service,
            Validation::Validator.new,
            logger
          )

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