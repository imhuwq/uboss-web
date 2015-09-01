require 'active_support/concern'

module Imagable
  extend ActiveSupport::Concern

  module ClassMethods
    def compatible_with_form_api_images(*columns)
      columns.each do |column|
        define_method "#{column}=" do |file|
          if file.present?
            if file.is_a?(String)
              write_uploader column, file
            else
              __send__("#{column}=", file)
            end
          end
          __send__(column)
        end
      end
    end
  end
end

