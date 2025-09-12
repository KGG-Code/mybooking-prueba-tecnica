module UseCase
  module RateType
    #
    # Use case to list all rate types with optional rental location filter
    #
    class ListRateTypesUseCase

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
      # @param [Hash] params - Parameters (rental_location_id is optional)
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
        
        log_message = if processed_params[:rental_location_id]
                        "loaded #{data.length} rate types for rental location #{processed_params[:rental_location_id]}"
                      else
                        "loaded #{data.length} rate types (all locations)"
                      end
        @logger.info "ListRateTypesUseCase - perform - #{log_message}"

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
        
        if rental_location_id
          validator = Validation::BaseValidator.new(params, { rental_location_id: [:required, :int] })
          validator.validate!
          rental_location_id = validator.data[:rental_location_id]
        end

        return { valid: true, authorized: true, rental_location_id: rental_location_id }
        
      rescue Errors::ValidationError => error
        return { valid: false, authorized: true, message: error.errors }
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
        
        if rental_location_id
          return { 
            category_rental_location_rate_types: { 
              rental_location_id: rental_location_id 
            } 
          }
        end
        
        return {}
      end

    end
  end
end