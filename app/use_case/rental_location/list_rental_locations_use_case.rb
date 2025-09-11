module UseCase
  module RentalLocation
    #
    # Use case to list all rental locations
    #
    class ListRentalLocationsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Repository::RentalLocationRepository] rental_location_repository
      # @param [Logger] logger
      #
      def initialize(rental_location_repository, logger)
        @rental_location_repository = rental_location_repository
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

        # Check valid
        unless processed_params[:valid]
          return Result.new(success?: false, authorized?: true, message: processed_params[:message])
        end

        # Check authorization
        unless processed_params[:authorized]
          return Result.new(success?: true, authorized?: false, message: 'Not authorized')
        end

        data = self.load_data
        @logger.info "ListRentalLocationsUseCase - execute - loaded #{data.length} rental locations"

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)

      end

      private

      def load_data

        @rental_location_repository.find_all(order: [:name.asc])

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