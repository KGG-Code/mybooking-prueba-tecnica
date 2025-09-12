module UseCase
  module Season
    #
    # Use case to list seasons filtered by season definition
    #
    class ListSeasonsBySeasonDefinitionUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param season_repository [Repository::SeasonRepository] The repository
      # @param validator [Object] Must respond to set_schema, validate!, data (duck typing)
      # @param logger [Logger] The logger
      #
      def initialize(season_repository, validator, logger)
        @season_repository = season_repository
        @validator = validator
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [Hash] params - Parameters including season_definition_id
      #
      # @return [Result]
      #
      def perform(params)
        
        processed_params = process_params(params)
    
        conditions = build_conditions(processed_params)
        data = load_data(conditions)
        
        @logger.info "ListSeasonsBySeasonDefinitionUseCase - perform - loaded #{data.length} seasons for season definition #{processed_params[:season_definition_id]}"

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data(conditions)
        @season_repository.find_all(
          conditions: conditions,
          order: [:name.asc]
        )
      end

      #
      # Process the parameters
      #
      # @return [Hash]
      #
      def process_params(params)

        season_definition_id = params[:season_definition_id] || params['season_definition_id']
        
        @validator.set_schema({ season_definition_id: [:required, :int] })
        @validator.validate!(params)

        return { valid: true, authorized: true, season_definition_id: @validator.data[:season_definition_id] }
      
      end

      #
      # Build conditions for the query
      #
      # @param [Hash] processed_params - Processed parameters
      #
      # @return [Hash] Conditions hash
      #
      def build_conditions(processed_params)
        season_definition_id = processed_params[:season_definition_id]
        { season_definition_id: season_definition_id }
      end

    end
  end
end