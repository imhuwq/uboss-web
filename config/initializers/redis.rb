redis_options = {
  host: Rails.application.secrets.redis_host,
  port: 6379,
  db: 2,
  driver: :hiredis
}

if Rails.env.production?
  redis_options = redis_options.merge(password: Rails.application.secrets.redis_pwd)
end

$redis = Redis.new(redis_options)
