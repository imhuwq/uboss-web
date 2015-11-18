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
              super(file)
            end
          end
          __send__(column)
        end
      end
    end

    def has_one_image(options = {})
      name = options.delete(:name) || :asset_img
      image_type = options.delete(:image_type) || name != :asset_img && "#{self.table_name}_#{name}"
      options = { class_name: 'AssetImg', as: :resource }.merge(options)

      if image_type
        has_one name, -> { where(image_type: image_type) }, options
      else
        has_one name, options
      end
    end

    def has_many_images(options = {})
      name = options.delete(:name) || :images
      image_type = options.delete(:image_type) || "#{self.table_name}_#{name}"
      accepts_nested = options.delete(:accepts_nested)
      options = { class_name: 'AssetImg', as: :resource }.merge(options)

      has_many name, -> { where(image_type: image_type) }, options

      if accepts_nested
        accepts_nested_attributes_for name
      end
    end
  end
end

