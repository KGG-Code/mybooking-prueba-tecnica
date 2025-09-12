module UseCase
  module Pricing
    #
    # Use case to list price definitions filtered by season definition
    #
    class ListPriceDefinitionsBySeasonDefinitionUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param pricing_service [Service::PricingService] The pricing service
      # @param validator [Object] Must respond to set_schema, validate!, data (duck typing)
      # @param logger [Logger] The logger
      #
      def initialize(pricing_service, validator, logger)
        @pricing_service = pricing_service
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
        
        @logger.info "ListPriceDefinitionsBySeasonDefinitionUseCase - perform - loaded #{data.length} price definitions for season definition #{processed_params[:season_definition_id]}"

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

      def load_data(conditions)
        season_definition_id = conditions[:season_definition_id]
        service_conditions = {}
        service_conditions[:season_definition_id] = season_definition_id unless season_definition_id.nil?
        
        @pricing_service.get_price_definitions(service_conditions)
      end

      #
      # Process the parameters
      #
      # @return [Hash]
      #
      def process_params(params)

        season_definition_id = params[:season_definition_id] || params['season_definition_id']
        
        @validator.set_schema({ season_definition_id: [:required, :nullable, :int] })
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