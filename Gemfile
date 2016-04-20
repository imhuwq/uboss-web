#source 'https://rubygems.org'
source 'https://ruby.taobao.org'

ruby '2.2.2'
gem 'rails', '4.2.5.1'

#DB
gem "pg"

# Reusable logic
gem 'devise'
gem "devise-async"
gem 'china_sms'
gem "cancancan", "~> 1.10"
gem "kaminari"
gem 'simple_captcha2', require: 'simple_captcha'
gem 'uuidtools'
gem 'aasm'
gem 'enum_help'
gem 'dalli' # memcache client
gem "browser", github: 'xEasy/browser'
gem 'wx_pay', github: 'xEasy/wx_pay'
gem 'weixin_authorize', github: "lanrion/weixin_authorize"
gem 'weixin_rails_middleware'
gem 'ransack'
gem 'rails-api'
gem 'sanitize'
gem 'rongcloud', github: 'xEasy/rongcloud'
gem "paper_trail", "~> 4.0.0" # modal versioning
gem 'realtime'

# copying of ActiveRecord objects and their associated children
gem 'amoeba'

# nested sharing_node
gem 'awesome_nested_set'
# order
gem 'acts_as_list'

#Front
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem "simple_form"
gem "tabletastic", path: "vendor/gems"
gem 'redactor-rails', github: 'xEasy/redactor-rails'
gem "jquery-fileupload-rails"
gem 'font-awesome-sass', '~> 4.4.0'
gem 'eco'
gem "select2-rails", '~> 3.5.9.1'
gem "simple-navigation"

# enum i18n
gem 'enumerize'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.2', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'

# JavaScript/Css stuff
gem "bootstrap-sass"
gem "underscore-rails"

# ImgTool
gem "carrierwave"
gem "carrierwave-upyun"
gem 'mini_magick'

# oauth
gem 'omniauth-wechat-oauth2', github: 'xEasy/omniauth-wechat-oauth2'

# redis
gem "redis", "~> 3.0", require: ["redis/connection/hiredis", "redis"]
gem "hiredis"
gem 'redis-rails'
gem "redis-namespace"

# backend process
gem 'sidekiq', '~> 3.5.1'
gem 'sidekiq-failures'
gem 'sinatra', :require => nil

# TOOLS
# app server
gem 'unicorn', require: false
gem 'unicorn-worker-killer', require: false
gem 'facter', require: false
# cronjob
gem 'whenever', :require => false

gem 'airbrake'
gem 'sucker_punch' # airbrake async use this

gem 'china_city'
gem 'nested_form'

# for generate excel
gem 'axlsx', '~> 2.0.1'

group :development do
  gem "thin"
  gem "capistrano"
  gem 'capistrano-rbenv'
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
  gem "slackistrano", require: false
  gem "better_errors"
  gem "quiet_assets"
  gem 'rack-mini-profiler', require: false
  gem 'awesome_print'
end

group :staging, :development do
  # 在线查询数据库
  gem 'rails_db'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem "pry-stack_explorer"
  gem "factory_girl_rails"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem "database_cleaner"
  gem "mocha"
  gem "test_after_commit"
  gem "webmock"
  gem "mock_redis" # Used for test
  gem "minitest-rails-capybara"
  gem 'm', '~> 1.3.1'
end
