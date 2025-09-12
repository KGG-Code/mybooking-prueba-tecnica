module UseCase
  module Season
    #
    # Use case to list all seasons
    #
    class ListSeasonsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Repository::SeasonRepository] season_repository
      # @param [Logger] logger
      #
      def initialize(season_repository, logger)
        @season_repository = season_repository
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
        
        processed_params = process_params(params)
        data = load_data
        @logger.info "ListSeasonsUseCase - perform - loaded #{data.length} seasons"

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data
        @season_repository.find_all(order: [:name.asc])
      end

      #
      # Process the parameters - no validation needed
      #
      # @return [Hash]
      #
      def process_params(params)
        return { valid: true, authorized: true }
      end

    end
  end
end