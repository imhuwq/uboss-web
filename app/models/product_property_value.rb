class ProductPropertyValue < ActiveRecord::Base
  belongs_to :product_property
  belongs_to :product_class
end
