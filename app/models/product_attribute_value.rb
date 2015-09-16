class ProductAttributeValue < ActiveRecord::Base
  belongs_to :product_attribute_name
  belongs_to :product_class
end
