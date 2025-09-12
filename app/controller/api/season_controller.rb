module Controller
  module Api
    module SeasonController
      def self.registered(app)
        # REST API end-point to list all seasons
        app.get '/api/seasons' do
          use_case = UseCase::Season::ListSeasonsUseCase.new(
            Repository::SeasonRepository.new,
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |season| serializer.serialize(season) }
            data.to_json
          end
        end

        # REST API end-point to list seasons filtered by season definition
        app.get '/api/seasons-by-season-definition' do
          use_case = UseCase::Season::ListSeasonsBySeasonDefinitionUseCase.new(
            Repository::SeasonRepository.new,
            Validation::Validator.new,
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |season| serializer.serialize(season) }
            data.to_json
          end
        end

      end
    end
  end
end