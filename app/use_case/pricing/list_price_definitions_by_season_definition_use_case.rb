require_relative '../../constants/time_unit_constants'

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
        service_conditions = {}
        service_conditions[:rental_location_id] = conditions[:rental_location_id] unless conditions[:rental_location_id].nil?
        service_conditions[:season_definition_id] = conditions[:season_definition_id] unless conditions[:season_definition_id].nil?
        service_conditions[:rate_type_id] = conditions[:rate_type_id] unless conditions[:rate_type_id].nil?
        service_conditions[:season_id] = conditions[:season_id] unless conditions[:season_id].nil?
        service_conditions[:unit] = conditions[:unit] unless conditions[:unit].nil?
        service_conditions[:page] = conditions[:page] unless conditions[:page].nil?
        service_conditions[:per_page] = conditions[:per_page] unless conditions[:per_page].nil?
        
        @pricing_service.get_price_definitions_paginated(service_conditions)
      end

      #
      # Process the parameters
      #
      # @return [Hash]
      #
      def process_params(params)
        rental_location_id = params[:rental_location_id] || params['rental_location_id']
        season_definition_id = params[:season_definition_id] || params['season_definition_id']
        rate_type_id = params[:rate_type_id] || params['rate_type_id']
        season_id = params[:season_id] || params['season_id']
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

        # Process season_definition_id and season_id to handle null/empty values
        season_definition_id = @validator.data[:season_definition_id]
        season_id = @validator.data[:season_id]
        
        # If season_definition_id is null, empty, or 'null', treat both as null
        if season_definition_id.nil? || season_definition_id.to_s.strip.empty? || season_definition_id.to_s.downcase == 'null'
          season_definition_id = nil
          season_id = nil
        end
        
        # If season_id is null, empty, or 'null', treat as null
        if season_id.nil? || season_id.to_s.strip.empty? || season_id.to_s.downcase == 'null'
          season_id = nil
        end

        return { 
          valid: true, 
          authorized: true, 
          rental_location_id: @validator.data[:rental_location_id],
          season_definition_id: season_definition_id,
          rate_type_id: @validator.data[:rate_type_id],
          season_id: season_id,
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
        {
          rental_location_id: processed_params[:rental_location_id],
          season_definition_id: processed_params[:season_definition_id],
          rate_type_id: processed_params[:rate_type_id],
          season_id: processed_params[:season_id],
          unit: processed_params[:unit],
          page: processed_params[:page],
          per_page: processed_params[:per_page]
        }
      end

    end
  end
end