class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :sharing_node

  validates :product_id, presence: true

  delegate :name, to: :product, prefix: true

  before_save :set_pay_amount
  after_create :decrease_product_stock
  after_save :update_order_pay_amount

  def recover_product_stock
    adjust_product_stock(1)
  end

  def decrease_product_stock
    adjust_product_stock(-1)
  end

  private

  def adjust_product_stock(type)
    if [1, -1].include?(type)
      Product.update_counters(product_id, count: amount * type)
    else
      raise 'Accept value is -1 or 1'
    end
  end

  def set_pay_amount
    self.pay_amount = product.present_price * amount.to_i
  end

  def update_order_pay_amount
    order.update_pay_amount
  end
end
