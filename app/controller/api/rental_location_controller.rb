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
          elsif !result.authorized?
            halt 401, { error: 'Unauthorized' }.to_json
          else
            halt 400, { error: result.message }.to_json
          end
        end

      end

    end
  end
end