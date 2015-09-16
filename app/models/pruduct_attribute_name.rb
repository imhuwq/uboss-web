class ProductAttributeName < ActiveRecord::Base
  belongs_to :product_class
  has_many :product_attribute_values, dependent: :destroy
end
