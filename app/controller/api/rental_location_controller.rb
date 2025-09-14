module Controller
  module Api
    module RentalLocationController

      def self.registered(app)

        #
        # REST API end-point to list all rental locations
        #
        app.get '/api/rental-locations' do

          use_case = UseCase::RentalLocation::ListRentalLocationsUseCase.new(
            Repository::RentalLocationRepository.new, 
            logger
          )
          result = use_case.perform(params)

          if result.success?
            content_type :json
            # Use the serializer to create a basic object with no dependencies on the ORM
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rental_location| serializer.serialize(rental_location) }
            data.to_json
          end
        end

        #
        # REST API end-point to list rate types for a specific rental location
        #
        app.get '/api/rental-locations/:id/rate-types' do
          rental_location_id = params[:id]
          
          use_case = UseCase::RateType::ListRateTypesByRentalLocationUseCase.new(
            Repository::RateTypeRepository.new,
            Validation::Validator.new,
            logger
          )
          
          result = use_case.perform({ rental_location_id: rental_location_id })

          if result.success?
            content_type :json
            serializer = Controller::Serializer::BaseSerializer.new
            data = result.data.map { |rate_type| serializer.serialize(rate_type) }
            data.to_json
          end
        end

      end

    end
  end
end