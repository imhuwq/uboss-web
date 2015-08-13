require "rake"
require "airbrake/rake_handler"

Airbrake.configure do |config|
  api_key        = Rails.env.production? ? '3b73c8421cf90fccd9b574d237caf97d' : '53ba15ae15505882c00122b48f307dac'
  config.api_key = api_key
  config.host    = 'errbit.uboss.me'
  config.port    = 80
  config.secure  = config.port == 443
  config.async   = true
  config.logger  = Logger.new("log/airbrake.log")
  config.rescue_rake_exceptions = true
  config.ignore_only  = []
end
