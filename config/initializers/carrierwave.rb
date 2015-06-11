CarrierWave.configure do |config|
  config.storage = :upyun

  config.upyun_username = Rails.application.secrets.upyun_username
  config.upyun_password = Rails.application.secrets.upyun_password
  config.upyun_bucket = Rails.application.secrets.upyun_bucket
  config.upyun_bucket_host = Rails.application.secrets.upyun_bucket_host
end
