Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Rails.application.secrets.redis_host}:6379/1", namespace: "ssobu_queues" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Rails.application.secrets.redis_host}:6379/1", namespace: "ssobu_queues" }
end
