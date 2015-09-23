class ProductProperty < ActiveRecord::Base
  belongs_to :product_class
  has_many :product_property_values, dependent: :destroy
end
