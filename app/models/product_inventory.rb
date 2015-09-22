class ProductInventory < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_attribute_value
  belongs_to :product_class
end
