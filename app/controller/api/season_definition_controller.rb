require_relative '../../validation/contracts/season_definition_contracts'

module Controller
  module Api
    module SeasonDefinitionController
      def self.registered(app)

        # REST API end-point to list all season definitions
        app.get '/api/open-season-definitions' do
          use_case = UseCase::SeasonDefinition::ListSeasonDefinitionsUseCase.new(
            Repository::SeasonDefinitionRepository.new,
            Validation::Validator.new(SeasonDefinitionFilterOpenParamsContract.new({})),
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |season_definition| serializer.serialize(season_definition) }
            data.to_json
          end
        end

        # REST API end-point to list season definitions filtered by rate type and rental location
        app.get '/api/season-definitions' do
          use_case = UseCase::SeasonDefinition::ListSeasonDefinitionsUseCase.new(
            Repository::SeasonDefinitionRepository.new,
            Validation::Validator.new(SeasonDefinitionFilterParamsContract.new({})),
            logger
          )

          result = use_case.perform(params)

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |season_definition| serializer.serialize(season_definition) }
            data.to_json
          end
        end

      end
    end
  end
end