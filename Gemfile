source 'https://rubygems.org'
# source 'https://ruby.taobao.org'

ruby '2.2.2'
gem 'rails', '4.2.2'

#DB
gem "pg"

# Reusable logic
gem 'devise'
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

# nested sharing_node
gem 'awesome_nested_set'

#Fornt
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem "simple_form"
gem "tabletastic", path: "vendor/gems"
gem 'redactor-rails', github: 'xEasy/redactor-rails'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

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
gem 'omniauth-wechat-oauth2'

# app server
gem 'unicorn', require: false

# redis
gem "redis", "~> 3.0", require: ["redis/connection/hiredis", "redis"]
gem "hiredis"
gem 'redis-rails'
gem "redis-namespace"

# backend process
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', :require => nil

group :development do
  gem "thin"
  gem "capistrano-rails"
  gem 'capistrano-rbenv'
  gem "slackistrano", require: false
  gem "better_errors"
  gem "quiet_assets"
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
end
