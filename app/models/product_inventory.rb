class ProductInventory < ActiveRecord::Base
  include DishesProductInventoryAble

  SkuProperty = Struct.new(:key, :value)

  belongs_to :product, inverse_of: :product_inventories
  belongs_to :product_class
  has_many   :cart_items
  has_many   :order_items
  has_many   :orders, through: :order_items
  has_many   :stock_movements

  validates_presence_of :sku_attributes, if: -> { self.saling }
  validates_numericality_of :price, :count, greater_than_or_equal_to: 0, if: -> { self.saling }
  
  validate :share_amount_total_must_lt_price

  scope :saling, -> { where(saling: true) }
  scope :not_saling, -> { where(saling: false) }

  delegate :image_url, :status, :traffic_expense, :carriage_template, :carriage_template_id, :transportation_way, :full_cut, :full_cut_number, :full_cut_unit, :is_official_agent?, to: :product

  # TODO custom properties
  # after_create :create_product_properties
  after_commit :update_unpay_order_items, on: :update, if: -> { price_or_share_amount_changes }

  has_paper_trail on: [:update],
    if: Proc.new { |inventory| inventory.orders.where(state: [1, 3]).exists? },
    only: [ :price,
            :share_amount_total,
            :share_amount_lv_1,
            :share_amount_lv_2,
            :share_amount_lv_3,
            :privilege_amount ]
  after_save :cache_product_money

  def saling?
    status == 'published' && saling && count > 0
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

  def max_privilege_amount
    @max_privilege_amount ||= share_amount_lv_1 + privilege_amount
  end

  def sku_attributes_str
    sku_attributes.inject([]) do |attributes, property|
      attributes << property.try(:join, ':')
    end.try(:join, ';')
  end

  def convert_into_cart_item(buy_count, sharing_code)
    CartItem.new(
      product_inventory_id: id,
      seller_id: user_id,
      count: buy_count,
      sharing_node: SharingNode.find_by(code: sharing_code)
    )
  end

  def properties
    @properties ||= sku_attributes.collect do |key, value|
      SkuProperty.new(key, value)
    end
  end

  def share_and_privilege_amount_total
    share_amount_lv_3 + share_amount_lv_2 + share_amount_lv_1 + privilege_amount
  end

  def adjust_count quantity
    self.with_lock do
      self.count = self.count.to_i + quantity
      self.save!
    end
  end

  private

  def update_unpay_order_items
    RecalculateOrderPaymentJob.perform_later(self)
  end

  def price_or_share_amount_changes
    (
      previous_changes.include?(:price) &&
      previous_changes[:price].first != previous_changes[:price].last
    ) || (
      previous_changes.include?(:share_amount_total) &&
      previous_changes[:share_amount_total].first != previous_changes[:share_amount_total].last
    )
  end

  def create_product_properties
    sku_attributes.each do |property_name, property_value|
      property = ProductProperty.find_or_create_by(name: property_name)
      ProductPropertyValue.find_or_create_by(product_property_id: property.id, value: property_value)
    end
  end

  def share_amount_total_must_lt_price
    if share_and_privilege_amount_total > price
      errors.add(:share_amount_total, '必须小于对应（商品/规格）的价格')
    end
  end

  def cache_product_money
    price_ranges = [*product.price_ranges, price.to_f].compact.sort
    if price_ranges.length > 2
      price_ranges = [price_ranges[0], price_ranges[-1]]
    else
      price_ranges
    end
    product.update(price_ranges: price_ranges.compact)
  end

end
