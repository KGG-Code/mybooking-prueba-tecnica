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
      # @param logger [Logger] The logger
      #
      def initialize(rate_type_repository, logger)
        @rate_type_repository = rate_type_repository
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
        
        unless processed_params[:valid]
          return Result.new(success?: false, authorized?: true, message: processed_params[:message])
        end

        unless processed_params[:authorized]
          return Result.new(success?: true, authorized?: false, message: 'Not authorized')
        end

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
        
        unless rental_location_id
          return { valid: false, authorized: true, message: 'rental_location_id parameter is required' }
        end

        validation_result = validate_rental_location_id(rental_location_id)
        unless validation_result[:valid]
          return { valid: false, authorized: true, message: validation_result[:message] }
        end

        return { valid: true, authorized: true, rental_location_id: validation_result[:rental_location_id] }
      end

      #
      # Build conditions for the query
      #
      # @param [Hash] processed_params - Processed parameters
      #
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

      #
      # Validate rental location ID
      #
      # @param [Object] rental_location_id - The ID to validate
      #
      # @return [Hash] Validation result
      #
      def validate_rental_location_id(rental_location_id)
        if rental_location_id.nil? || rental_location_id.to_s.strip.empty?
          return { valid: false, message: 'rental_location_id is required' }
        end
        
        unless rental_location_id.to_s.match?(/^\d+$/)
          return { valid: false, message: 'rental_location_id must be a valid integer' }
        end
        
        rental_location_id = rental_location_id.to_i
        
        if rental_location_id <= 0
          return { valid: false, message: 'rental_location_id must be a positive integer' }
        end

        return { valid: true, rental_location_id: rental_location_id }
      end

    end
  end
end