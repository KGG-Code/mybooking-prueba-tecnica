module UseCase
  module Pricing
    #
    # Use case to list all price definitions
    #
    class ListPriceDefinitionsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Service::PricingService] pricing_service
      # @param [Logger] logger
      #
      def initialize(pricing_service, logger)
        @pricing_service = pricing_service
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
        @logger.info "ListPriceDefinitionsUseCase - perform - loaded #{data.length} price definitions"

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data
        @pricing_service.get_price_definitions
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