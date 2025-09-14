module Controller
  module Api
    module ImportController
      def self.registered(app)
        
        # Endpoint para subir CSV de precios
        app.post '/api/import/prices' do
          file = params.dig(:file, :tempfile) or halt 400, "Archivo requerido"
          
          price_repository  = Repository::PriceRepository.new
          import_service    = Service::ImportPrices.new(price_repository, logger: logger)
          validator         = Validation::Validator.new
          use_case          = UseCase::Import::ImportPricesCsvUseCase.new(import_service, validator, logger)
          result = use_case.perform(file.path)
          
          if result.success?
            content_type :json
            { status: "success", message: "Importación completada" }.to_json
          end
        end

        # Endpoint para mostrar formulario de importación (opcional)
        app.get '/imports/prices' do
          erb :import_prices_form
        end
      
      end
    end
  end
end