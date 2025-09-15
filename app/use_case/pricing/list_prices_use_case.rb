module UseCase
  module Pricing
    #
    # Use case to list prices
    #
    class ListPricesUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, :errors, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Service::PricingService] pricing_service
      # @param [Validation::Validator] validator
      # @param [Logger] logger
      #
      def initialize(pricing_service, validator, logger)
        @pricing_service = pricing_service
        @validator = validator
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

        validated_params = process_params(params)
        data = load_data(validated_params)
        @logger.info "ListPricesUseCase - perform - loaded #{data.length} price definitions"

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data(conditions)
        @pricing_service.get_price_definitions_paginated(conditions)
      end

      #
      # Process the parameters - extract optional filters
      #
      # @return [Hash]
      #
      def process_params(params)
        @validator.validate!(params)
      end

    end
  end
end