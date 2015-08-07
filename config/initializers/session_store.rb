# Be sure to restart your server when you modify this file.

redis_options = {
  host: Rails.application.secrets.redis_host,
  port: 6379,
  db: 1,
  namespace: "uboss_session",
  domain: :all,
}

# if Rails.env.production?
#   redis_options = redis_options.merge(password: Rails.application.secrets.redis_pwd)
# end

Rails.application.config.session_store :redis_store, servers: redis_options, :expires_in => 2.weeks
