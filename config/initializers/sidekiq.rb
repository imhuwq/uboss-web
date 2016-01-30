Sidekiq.configure_server do |config|

  config.redis = {
    url: "redis://#{Rails.application.secrets.redis_host}:6379/1",
    namespace: "ssobu_queues"
  }

  db_config = ActiveRecord::Base.configurations[Rails.env] ||
    Rails.application.config.database_configuration[Rails.env]
  default_pool_size = Rails.env.production? ? 35 : 5
  db_config['pool'] = ENV['DB_POOL'] || ENV['MAX_THREADS'] || default_pool_size

  ActiveRecord::Base.establish_connection(db_config)

end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Rails.application.secrets.redis_host}:6379/1", namespace: "ssobu_queues" }
end
