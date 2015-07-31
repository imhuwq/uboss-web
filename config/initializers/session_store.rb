# Be sure to restart your server when you modify this file.
if Rails.env.production? || Rails.env.staging?

  redis_options = {
    host: Rails.application.secrets.redis_host,
    port: 6379,
    db: 1,
    namespace: "uboss_session",
    domain: :all,
  }

  #if Rails.env.production?
    #redis_options = redis_options.merge(password: Rails.application.secrets.redis_pwd)
  #end

  Rails.application.config.session_store :redis_store, servers: redis_options, :expires_in => 120.minutes

else

  Rails.application.config.session_store :cookie_store, key: '_UBoss_session', domain: :all

end
