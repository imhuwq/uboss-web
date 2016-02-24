require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UBoss
  class Application < Rails::Application

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # config.autoload_paths += %W(#{config.root}/app/validators)

    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'

    config.active_job.queue_adapter = :sidekiq

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    #config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :"zh-CN"

    config.api_only = false

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.helper_specs false
      g.view_specs false
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # Do not raise exception while unpermitter paraters
    config.action_controller.action_on_unpermitted_parameters = :log
  end
end
