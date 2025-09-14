require_relative 'config/application'

# Require error classes
require_relative 'app/errors/base_error'
require_relative 'app/errors/validation_error'
require_relative 'app/errors/not_found_error'
require_relative 'app/errors/unauthorized_error'
require_relative 'app/errors/export_error'

# Setup rack session
use Rack::Session::Cookie, :secret => ENV['COOKIE_SECRET'],
                           :key => 'rack.session',
                           :path => '/',
                           :expire_after => 86400

# Setup error handler middleware
require_relative 'app/middlewares/error_handler'
use ErrorHandler, logger: Logger.new(STDOUT)

# Setup sinatra application
require_relative 'sinatra_application'
app = Rack::Builder.new do
  map "/" do
    run Sinatra::Application
  end
end

run app

# Prepare debug
if File.exist?('debug.txt')
  ENV['RUBY_DEBUG_NONSTOP'] = '1'
  ENV['RUBY_DEBUG_OPEN'] = 'tcp://127.0.0.1:1235'
  ENV['RUBY_DEBUG_HOST'] = '127.0.0.1'
  ENV['RUBY_DEBUG_PORT'] = '1235'
  ENV['RUBY_DEBUG_USE_SOCKET'] = 'tcp'
  require 'debug/open_nonstop'
end
