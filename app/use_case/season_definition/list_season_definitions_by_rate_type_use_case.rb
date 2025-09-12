module UseCase
  module SeasonDefinition
    #
    # Use case to list season definitions filtered by rate type and rental location
    # Based on price definitions that connect rate types with season definitions for specific rental locations
    #
    class ListSeasonDefinitionsByRateTypeUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param season_definition_repository [Repository::SeasonDefinitionRepository] The repository
      # @param validator [Object] Must respond to set_schema, validate!, data (duck typing)
      # @param logger [Logger] The logger
      #
      def initialize(season_definition_repository, validator, logger)
        @season_definition_repository = season_definition_repository
        @validator = validator
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [Hash] params - Parameters including rate_type_id and rental_location_id
      #
      # @return [Result]
      #
      def perform(params)
        processed_params = process_params(params)
        conditions = build_conditions(processed_params)
        data = load_data(conditions)
        
        @logger.info "ListSeasonDefinitionsByRateTypeUseCase - loaded #{data.length} season definitions for rate_type #{processed_params[:rate_type_id]} and rental_location #{processed_params[:rental_location_id]}"

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data(conditions)
      
        @season_definition_repository.find_all(
          conditions: conditions,
          order: [:name.asc]
        )

      end

      #
      # Process the parameters
      #
      # @param [Hash] params - Parameters including rate_type_id and rental_location_id
      #
      # @return [Hash] Processed parameters
      #
      def process_params(params)
        
        rate_type_id = params[:rate_type_id] || params['rate_type_id']
        rental_location_id = params[:rental_location_id] || params['rental_location_id']
        
        @validator.set_schema({ 
          rate_type_id: [:required, :int],
          rental_location_id: [:required, :int]
        })
        @validator.validate!(params)

        return { 
          valid: true, 
          authorized: true, 
          rate_type_id: @validator.data[:rate_type_id],
          rental_location_id: @validator.data[:rental_location_id]
        }
      end

      #
      # Build conditions for the query
      #
      # @param [Hash] processed_params - Processed parameters
      #
      # @return [Hash] Conditions hash
      #
      def build_conditions(processed_params)
        rate_type_id = processed_params[:rate_type_id]
        rental_location_id = processed_params[:rental_location_id]
        {
          price_definitions: {
            category_rental_location_rate_types: {
              rate_type_id: rate_type_id,
              rental_location_id: rental_location_id
            }
          }
        }
      end
    end
  end
end