class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :product_inventory
  belongs_to :sharing_node
  has_many   :evaluations
  has_many   :sharing_incomes
  has_many   :order_item_refunds

  validates :user, :product_inventory, :amount, :present_price, :pay_amount, presence: true

  delegate :name, :traffic_expense, to: :product, prefix: true
  delegate :product_name, :price, :sku_attributes, :sku_attributes_str, to: :product_inventory
  delegate :privilege_card, to: :sharing_node, allow_nil: true

  # 1 退款, 2 退款不退货, 3 退款退货, 4 退款中, 5 退款成功, 6 退款关闭, 7 UBOSS介入
  enum refund_state: { nothing: 0, refund: 1, unreturn_good: 2, return_good: 3, refunding: 4, refunded: 5, refund_close: 6, uboss_deal: 7 }

  before_validation :set_product_id
  before_save  :reset_payment_info, if: -> { order.paid_at.blank? }
  after_create :decrease_product_stock
  after_commit :update_order_pay_amount, if: -> {
    previous_changes.include?(:pay_amount) &&
    previous_changes[:pay_amount].first != previous_changes[:pay_amount].last
  }

  def deal_price
    present_price - privilege_amount
  end

  def last_refund
    order_item_refunds.reorder("created_at desc").first
  end

  def count
    amount
  end

  def item_product
    product || product_inventory.product
  end

  def product_name
    product.try(:name) || product_inventory.product.name
  end

  def image_url(version=nil)
    item_product.image_url(version)
  end

  def sharing_link_node
    @sharing_link_node ||= SharingNode.find_or_create_by(
      user_id: user_id,
      product_id: product_id,
      parent_id: sharing_node_id
    )
  end
  alias_method :generate_sharing_link_node, :sharing_link_node

  def create_privilege_card_if_none
    PrivilegeCard.find_or_active_card(user_id, order.seller_id)
  end

  def active_privilege_card
    if card = PrivilegeCard.find_by(user_id: user_id, seller_id: order.seller_id, actived: false)
      card.update_column(:actived, true)
    end
  end

  def recover_product_stock
    adjust_product_stock(1)
  end

  def decrease_product_stock
    adjust_product_stock(-1)
  end

  def reset_payment_info
    set_privilege_amount
    set_present_price
    set_pay_amount
  end

  private

  def adjust_product_stock(type)
    if [1, -1].include?(type)
      ProductInventory.update_counters(product_inventory_id, count: amount * type)
    else
      raise 'Accept value is -1 or 1'
    end
  end

  def set_privilege_amount
    self.privilege_amount = privilege_card.present? ? privilege_card.privilege_amount(product_inventory) : 0
  end

  def set_present_price
    self.present_price = if product_inventory.present?
                           product_inventory.price
                         else
                           product.price
                         end
  end

  def set_pay_amount
    self.pay_amount = deal_price * amount
  end

  def update_order_pay_amount
    order.update_pay_amount
  end

  def set_product_id
    if product_inventory && product_id.blank?
      self.product_id = self.product_inventory.product_id
    end
  end
end
