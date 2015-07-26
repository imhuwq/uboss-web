require 'active_support/concern'

module Loggerable
  extend ActiveSupport::Concern

  included do |base|
    loggerable(base.name.underscore)
  end

  module ClassMethods
    def loggerable(file_name)
      define_method :logger do
        return @logger if @logger.present?
        @logger ||= Logger.new(
          File.expand_path(File.join(Rails.root, "log/#{file_name}.log"), __FILE__), 10, 1024_000)
        @logger.level = Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{severity}] #{datetime}: #{msg}\n"
        end
        @logger
      end
    end
  end

end
