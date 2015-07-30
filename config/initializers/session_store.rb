# Be sure to restart your server when you modify this file.
if Rails.env.production? || Rails.env.staging?
  Rails.application.config.session_store :redis_store, servers: {
    host: Rails.application.secrets.redis_host,
    port: 6379,
    db: 0,
    namespace: "uboss_session",
    domain: :all,
  },
  :expires_in => 120.minutes
else
  Rails.application.config.session_store :cookie_store, key: '_UBoss_session', domain: :all
end
