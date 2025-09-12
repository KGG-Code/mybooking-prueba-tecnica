module Controller
  module Api
    module RateTypeController
      def self.registered(app)
        # REST API end-point to list rate types with optional rental location filter
        app.get '/api/rate-types' do
          use_case = UseCase::RateType::ListRateTypesUseCase.new(
            Repository::RateTypeRepository.new,
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rate_type| serializer.serialize(rate_type) }
            data.to_json
          elsif !result.authorized?
            halt 401, { error: 'Unauthorized' }.to_json
          else
            halt 400, { error: result.message }.to_json
          end
        end

        # REST API end-point to list rate types filtered by rental location
        app.get '/api/rate-types-by-rental-location' do
          use_case = UseCase::RateType::ListRateTypesByRentalLocationUseCase.new(
            Repository::RateTypeRepository.new,
            Validation::Validator.new,
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rate_type| serializer.serialize(rate_type) }
            data.to_json
          elsif !result.authorized?
            halt 401, { error: 'Unauthorized' }.to_json
          else
            halt 400, { error: result.message }.to_json
          end
        end
      end
    end
  end
end