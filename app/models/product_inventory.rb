class ProductInventory < ActiveRecord::Base

  belongs_to :product
  belongs_to :product_class
  has_many   :cart_items
  has_many   :order_items

  validates_presence_of :product

  scope :saling, -> { where(saling: true) }
  scope :not_saling, -> { where(saling: false) }

  delegate :image_url, :status, :traffic_expense, :carriage_template, :carriage_template_id, :transportation_way, :is_official_agent?, to: :product

  after_create :create_product_properties

  def published?
    status == 'published'
  end

  def product_name
    product.name
  end

  def seller
    product.user
  end

  def seller_id
    seller.id
  end

  def sku_attributes_str
    sku_attributes.inject([]) do |attributes, property|
      attributes << property.try(:join, ':')
    end.try(:join, ';')
  end

  def convert_into_cart_item(buy_count, sharing_code)
    {
      seller => [
        CartItem.new(
          product_inventory_id: id,
          seller_id: user_id,
          count: buy_count,
          sharing_node: SharingNode.find_by(code: sharing_code)
        )
      ]
    }
  end

  SkuProperty = Struct.new(:key, :value)
  def properties
    @properties ||= sku_attributes.collect do |key, value|
      SkuProperty.new(key, value)
    end
  end

  private

  def create_product_properties
    sku_attributes.each do |property_name, property_value|
      property = ProductProperty.find_or_create_by(name: property_name)
      ProductPropertyValue.find_or_create_by(product_property_id: property.id, value: property_value)
    end
  end

end
