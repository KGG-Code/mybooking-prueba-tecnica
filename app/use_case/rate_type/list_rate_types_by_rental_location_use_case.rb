module UseCase
  module RateType
    #
    # Use case to list rate types filtered by rental location
    #
    class ListRateTypesByRentalLocationUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param rate_type_repository [Repository::RateTypeRepository] The repository
      # @param validator [Object] Must respond to set_schema, validate!, data (duck typing)
      # @param logger [Logger] The logger
      #
      def initialize(rate_type_repository, validator, logger)
        @rate_type_repository = rate_type_repository
        @validator = validator
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [Hash] params - Parameters including rental_location_id
      #
      # @return [Result]
      #
      def perform(params)
        processed_params = process_params(params)
        conditions = build_conditions(processed_params)
        data = load_data(conditions)
        
        @logger.info "ListRateTypesByRentalLocationUseCase - perform - loaded #{data.length} rate types for rental location #{processed_params[:rental_location_id]}"

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data(conditions)

        @rate_type_repository.find_all(
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

        rental_location_id = params[:rental_location_id] || params['rental_location_id']
        
        @validator.set_schema({ rental_location_id: [:required, :int] })
        @validator.validate!(params)

        return { valid: true, authorized: true, rental_location_id: @validator.data[:rental_location_id] }

      end

      #
      # Build conditions for the query
      #
      # @param [Hash] processed_params - Processed parameters
      #()
      # @return [Hash] Conditions hash
      #
      def build_conditions(processed_params)
        rental_location_id = processed_params[:rental_location_id]
        { 
          category_rental_location_rate_types: { 
            rental_location_id: rental_location_id 
          } 
        }
      end

    end
  end
end