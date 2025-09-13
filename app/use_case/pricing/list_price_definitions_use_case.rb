require_relative '../../constants/time_unit_constants'

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
        processed_params = process_params(params)
        conditions = build_conditions(processed_params)
        data = load_data(conditions)
        @logger.info "ListPriceDefinitionsUseCase - perform - loaded #{data.length} price definitions"

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
        rental_location_id = params[:rental_location_id] || params['rental_location_id']
        season_definition_id = params[:season_definition_id] || params['season_definition_id']
        rate_type_id = params[:rate_type_id] || params['rate_type_id']
        season_id = params[:season_id] || params['season_id']
        unit = params[:unit] || params['unit']
        page = params[:page] || params['page']
        per_page = params[:per_page] || params['per_page']
        
        @validator.set_schema({ 
          rental_location_id: [:optional, :int],
          season_definition_id: [:optional, :nullable, :int],
          rate_type_id: [:optional, :int],
          season_id: [:optional, :nullable, :int],
          unit: [:optional, [:enum, *TimeUnitConstants::VALID_TIME_UNITS]],
          page: [:optional, :int],
          per_page: [:optional, :int]
        })
        @validator.validate!(params)
        
        return { 
          valid: true, 
          authorized: true, 
          rental_location_id: @validator.data[:rental_location_id],
          season_definition_id: @validator.data[:season_definition_id],
          rate_type_id: @validator.data[:rate_type_id],
          season_id: @validator.data[:season_id],
          unit: @validator.data[:unit],
          page: @validator.data[:page],
          per_page: @validator.data[:per_page]
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
        conditions = {}
        conditions[:rental_location_id] = processed_params[:rental_location_id] unless processed_params[:rental_location_id].nil?
        conditions[:season_definition_id] = processed_params[:season_definition_id] unless processed_params[:season_definition_id].nil?
        conditions[:rate_type_id] = processed_params[:rate_type_id] unless processed_params[:rate_type_id].nil?
        conditions[:season_id] = processed_params[:season_id] unless processed_params[:season_id].nil?
        conditions[:unit] = processed_params[:unit] unless processed_params[:unit].nil?
        conditions[:page] = processed_params[:page] unless processed_params[:page].nil?
        conditions[:per_page] = processed_params[:per_page] unless processed_params[:per_page].nil?
        conditions
      end

    end
  end
end