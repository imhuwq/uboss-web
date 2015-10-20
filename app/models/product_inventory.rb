class ProductInventory < ActiveRecord::Base

  belongs_to :product
  belongs_to :product_class
  has_many   :cart_items
  has_many   :order_items

  validates_presence_of :product_id

  scope :saling, -> { where(saling: true) }
  scope :not_saling, -> { where(saling: false) }

  delegate :image_url, :status, :traffic_expense, :carriage_template, :carriage_template_id, :transportation_way, :is_official_agent?, to: :product

  after_create :create_product_properties
  before_save :calculate_sharing_amount, if: -> { price_changed? }

  def published?
    status == 'published'
  end

  # FIXME product_inventory.name 没有用处
  # XXX: 商品名展示 product_inventory.name 还是 product.name ?
  def product_name
    name.present? ? name : product.name
  end

  def seller
    product.user
  end

  def seller_id
    seller.id
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

  def calculate_sharing_amount(changed_product = nil)
    assigned_total = 0
    changed_product ||= self.product

    self.share_amount_total = (price * changed_product.share_rate_total).to_i / 100
    3.times do |index|
      level = index + 1
      amount = (self.share_amount_total * changed_product["share_rate_lv_#{level}"]).round(2)
      __send__("share_amount_lv_#{level}=", amount)
      assigned_total += amount
    end
    last_amount = share_amount_total - assigned_total
    self.privilege_amount = last_amount > 0 ? last_amount : 0
  end

  private

  def create_product_properties
    sku_attributes.each do |property_name, property_value|
      property = ProductProperty.find_or_create_by(name: property_name)
      ProductPropertyValue.find_or_create_by(product_property_id: property.id, value: property_value)
    end
  end

end
