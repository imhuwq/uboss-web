class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :sharing_node
  has_one    :evaluation
  has_many   :sharing_incomes

  validates :product_id, presence: true

  delegate :name, :traffic_expense, :present_price, to: :product, prefix: true
  delegate :privilege_card, to: :sharing_node, allow_nil: true

  before_save :set_privilege_amount, :set_present_price,
    :set_pay_amount, if: -> { order.paid_at.blank? }
  after_create :decrease_product_stock
  after_commit :update_order_pay_amount, if: -> {
    previous_changes.include?(:pay_amount) &&
    previous_changes[:pay_amount].first != previous_changes[:pay_amount].last
  }

  def sharing_link_node
    @sharing_link_node ||= SharingNode.find_or_create_by(
      user_id: user_id,
      product_id: product_id,
      parent_id: sharing_node_id
    )
  end
  alias_method :generate_sharing_link_node, :sharing_link_node

  def create_privilege_card_if_none
    PrivilegeCard.find_or_active_card(user_id, product.user_id)
  end

  def active_privilege_card
    if card = PrivilegeCard.find_by(user_id: user_id, seller_id: product.user_id, actived: false)
      card.update_column(:actived, true)
    end
  end

  def recover_product_stock
    adjust_product_stock(1)
  end

  def decrease_product_stock
    adjust_product_stock(-1)
  end

  def deal_price
    present_price - privilege_amount
  end

  private

  def adjust_product_stock(type)
    if [1, -1].include?(type)
      Product.update_counters(product_id, count: amount * type)
    else
      raise 'Accept value is -1 or 1'
    end
  end

  def set_privilege_amount
    self.privilege_amount = privilege_card.present? ? privilege_card.privilege_amount(product) : 0
  end

  def set_present_price
    self.present_price = product.present_price
  end

  def set_pay_amount
    self.pay_amount = deal_price * amount + product.traffic_expense
  end


  def update_order_pay_amount
    order.update_pay_amount
  end
end
