module UseCase
  module SeasonDefinition
    #
    # Use case to list all season definitions
    #
    class ListSeasonDefinitionsUseCase
      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param season_definition_repository [Repository::SeasonDefinitionRepository] The repository
      # @param logger [Logger] The logger
      #
      def initialize(season_definition_repository, logger)
        @season_definition_repository = season_definition_repository
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [Hash] params - Not used, kept for interface compatibility
      #
      # @return [Result]
      #
      def perform(params)
        data = load_data
        @logger.info "ListSeasonDefinitionsUseCase - loaded #{data.length} season definitions"

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data
        @season_definition_repository.find_all(order: [:name.asc])
      end
    end
  end
end