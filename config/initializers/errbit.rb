if Rails.env.production?
  Airbrake.configure do |config|
    config.api_key = '3b73c8421cf90fccd9b574d237caf97d'
    config.host    = 'errbit.uboss.cc'
    config.port    = 80
    config.async   = true
    config.secure  = config.port == 443
  end
elsif Rails.env.staging?
  Airbrake.configure do |config|
    config.api_key = '53ba15ae15505882c00122b48f307dac'
    config.host    = 'errbit.uboss.cc'
    config.port    = 80
    config.async   = true
    config.secure  = config.port == 443
  end
end
