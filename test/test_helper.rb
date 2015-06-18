ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"

require 'minitest/spec'
require "minitest/pride"
require "minitest/rails/capybara"

# require 'mocha/setup'
# require 'mocha/mini_test'

require 'webmock/minitest'
require 'sidekiq/testing'

Dir[File.expand_path("../supports/*.rb", __FILE__)].each { |f| require f }

ActiveRecord::Migration.check_pending!

DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase

  include Warden::Test::Helpers
  include FactoryGirl::Syntax::Methods
  extend MiniTest::Spec::DSL

  before :each do
    DatabaseCleaner.start
    Sidekiq::Worker.clear_all
  end

  after :each do
    DatabaseCleaner.clean
  end

  def inline_sidekiq
    Sidekiq::Testing.inline!
  end

  def response_hash
    json = ActiveSupport::JSON.decode(response.body)
    json.is_a?(Hash) ? json.with_indifferent_access : json
  end
end
