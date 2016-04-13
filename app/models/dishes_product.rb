class DishesProduct < Product
  belongs_to :service_store
  scope :with_store, ->(store) { where(user_id: store.user_id) }

  validates_numericality_of :rebate_amount, if: "rebate_amount"
  validate :rebaste_amount_less_price
  validates_presence_of :present_price
  validates_presence_of :product_inventories

  after_create :create_default_category
  after_update :create_default_category

  def today_verify_code_count
    codes = VerifyCode.today(user).where(target_type: 'DishesOrder')
    a = codes.map do |code|
      code.target.order_items.where(product_id: id).sum(:amount)
    end.sum
  end

  def total_verify_code_count
    codes = VerifyCode.total(user).where(target_type: 'DishesOrder')
    codes.map do |code|
      code.target.order_items.where(product_id: id).sum(:amount)
    end.sum
  end

  def categories=(id)
    self.categories.destroy_all
    self.categories << Category.where(id: id)
  end

  def price_range
    if product_inventories.present?
      min_value = product_inventories.min_by { |a| a.price }.price
      max_value = product_inventories.max_by { |a| a.price }.price
      min_value != max_value ? "#{min_value} - #{max_value}" : min_value
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
  def create_default_category
    if self.categories.blank?
      self.categories << user.categories.find_or_create_by(name: '其他', store_id: user.service_store.id, store_type: user.service_store.class.name)
    end
  end

  def rebaste_amount_less_price
    errors.add(:rebate_amount, '不能大于现价') if self.rebate_amount.present? && self.rebate_amount.to_i > self.present_price.to_i
  end
end
