$redis = Redis.new(
  url: "redis://#{Rails.application.secrets.redis_host}:6379/2",
  driver: :hiredis
)
