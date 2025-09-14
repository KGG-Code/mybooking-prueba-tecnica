module Controller
  module Page
    module PricingLandingController
      def self.registered(app)
        # Landing page for pricing management
        app.get '/pricing' do
          erb :pricing_landing, layout: false
        end
      end
    end
  end
end