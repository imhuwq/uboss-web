class ProductClass < ActiveRecord::Base
  has_many :product_attribute_names, dependent: :destroy
  has_many :product_attribute_values, dependent: :destroy
  has_many :children, :class_name=>'ProductClass', :foreign_key=>'parent_id', dependent: :destroy
end
