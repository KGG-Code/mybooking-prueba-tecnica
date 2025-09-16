require_relative '../../validation/contracts/rate_type_contracts'

module Controller
  module Api
    module RateTypeController
      def self.registered(app)
        
        # REST API end-point to list rate types with optional rental location filter
        app.get '/api/open-rate-types' do
          use_case = UseCase::RateType::ListRateTypesUseCase.new(
            Repository::RateTypeRepository.new,
            Validation::Validator.new(RateTypeFilterOpenParamsContract.new({})),
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rate_type| serializer.serialize(rate_type) }
            data.to_json
          end
        end

        # REST API end-point to list rate types filtered by rental location
        app.get '/api/rate-types' do
          
          use_case = UseCase::RateType::ListRateTypesUseCase.new(
            Repository::RateTypeRepository.new,
            Validation::Validator.new(RateTypeFilterParamsContract.new({})),
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rate_type| serializer.serialize(rate_type) }
            data.to_json
          end
        end
      end
    end
  end
end