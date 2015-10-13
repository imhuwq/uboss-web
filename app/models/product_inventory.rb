class ProductInventory < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_property_value
  belongs_to :product_class
  belongs_to :user
end
