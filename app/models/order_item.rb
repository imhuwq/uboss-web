class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :sharing_node
  has_one    :evaluation

  validates :product_id, presence: true

  delegate :name, :traffic_expense, :present_price, to: :product, prefix: true
  delegate :privilege_card, to: :sharing_node, allow_nil: true

  before_save :set_present_price, :set_pay_amount
  after_create :decrease_product_stock
  after_save :update_order_pay_amount

  def sharing_link_node
    @sharing_link_node ||= SharingNode.find_or_create_by(
      user_id: user_id,
      product_id: product_id,
      parent_id: sharing_node_id
    )
  end

  def create_privilege_card_if_none
    PrivilegeCard.find_or_create_by(user_id: user_id, product_id: product_id)
  end

  def active_privilege_card
    if card = PrivilegeCard.find_by(user_id: user_id, product_id: product_id, actived: false)
      card.update_column(:actived, true)
    end
  end

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

  def set_present_price
    privilege_amount = privilege_card.present? ? privilege_card.privilege_amount : 0
    self.present_price = product.present_price - privilege_amount
  end

  def set_pay_amount
    self.pay_amount = present_price * amount + product.traffic_expense
  end

  def update_order_pay_amount
    order.update_pay_amount
  end
end
