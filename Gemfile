# source 'https://rubygems.org'
source 'https://ruby.taobao.org'

gem 'rails', '4.2.1'

#DB
gem "pg"

# Reusable logic
gem 'devise'
gem 'china_sms'
gem "cancancan", "~> 1.10"
gem "kaminari"
gem 'simple_captcha2', require: 'simple_captcha'
gem 'uuidtools'

#Fornt
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'simple_form'
gem 'will_paginate-bootstrap'
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
gem 'mini_magick'


# oauth
gem 'omniauth-oauth2'


gem 'unicorn', require: false

group :development do
  gem "thin"
  gem "capistrano-rails"
  gem 'capistrano-rbenv'
  gem "slackistrano", require: false
  gem "better_errors"
  gem "quiet_assets"
  gem "mock_redis" # Used for test
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
  gem "mocha", '~> 0.14', require: false
  gem "test_after_commit"
  gem "webmock"
end
