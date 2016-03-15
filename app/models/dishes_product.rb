class DishesProduct < Product
  belongs_to :service_store

  validates_numericality_of :rebate_amount, if: "rebate_amount"
  after_initialize  :initialize_product_inventory
  before_update :check_product_inventory_count


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

  def attr_min()
  end

  private
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
