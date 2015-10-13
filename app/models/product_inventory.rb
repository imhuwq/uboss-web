class ProductInventory < ActiveRecord::Base

  belongs_to :product
  belongs_to :product_property_value
  belongs_to :product_class

  after_create :create_product_properties

  private
  def create_product_properties
    sku_attributes.each do |property_name, property_value|
      property = ProductProperty.find_or_create_by(name: property_name)
      ProductPropertyValue.find_or_create_by(product_property_id: property.id, value: property_value)
    end
  end
end
