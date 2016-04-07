class DishesProduct < Product
  belongs_to :service_store
  scope :with_store, ->(store) { where(user_id: store.user_id) }

  validates_numericality_of :rebate_amount, if: "rebate_amount"
  after_initialize  :initialize_product_inventory
  before_update :check_product_inventory_count
  validate :rebaste_amount_less_price
  validates_presence_of :present_price
  validates_presence_of :product_inventories
  validates_presence_of :categories

  def today_verify_code
    VerifyCode.where(dishes_order_id: self.user.dishes_order_ids, verified: true).where('updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day)
  end

  def total_verify_code
    VerifyCode.where(dishes_order_id: self.user.dishes_order_ids, verified: true)
  end

  def price_range
    if product_inventories.present?
      "#{product_inventories.min_by { |a| a.price }.price} - #{product_inventories.max_by { |a| a.price }.price}"
    else
      self.present_price
    end
  end

  def rebate_amount_range
    if product_inventories.present?
      "#{product_inventories.min_by { |a| a.share_amount_total }.share_amount_total} - #{product_inventories.max_by { |a| a.share_amount_total }.share_amount_total}"
    else
      self.rebate_amount
    end
  end

  def deadline
  end

  def attr_min()
  end

  def optional_image?
    true
  end

  private
  def rebaste_amount_less_price
    errors.add(:rebate_amount, '不能大于现价') if self.rebate_amount.present? && self.rebate_amount > self.present_price
  end

  def initialize_product_inventory
    if self.new_record? && self.product_inventories.present?
      self.product_inventories.each do |inventory|
        inventory.count = 9*10000
      end
    end
  end

  def check_product_inventory_count
    if self.product_inventories.present?
      self.product_inventories.each do |inventory|
        inventory.update(count: 9*10000) if inventory.count < 10000
      end
    end
  end
end
