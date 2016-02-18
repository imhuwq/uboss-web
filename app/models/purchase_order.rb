class PurchaseOrder < ActiveRecord::Base
  include AASM
  include Numberable
  belongs_to :order
  belongs_to :seller, class_name: 'User'
  has_many :order_items, through: :order
  validates_uniqueness_of :number, allow_blank: true
  validates :order, presence: true, uniqueness: true

  delegate :mobile, :regist_mobile, :identify, to: :seller, prefix: true, allow: nil
  delegate :ship_price, :to_seller, to: :order, prefix: true
  attr_accessor :express_name, :ship_number, :express_id

  scope :with_refunds, -> { joins(order_items: :order_item_refunds).uniq }
  scope :today, -> (date=Date.today) { where(['DATE(purchase_orders.created_at) = ?', date]) }
  scope :week, -> (time=Time.now) { where(created_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { where(created_at: time.beginning_of_month..time.end_of_month) }

  before_create :set_default_values, if: :order

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  scope :with_payed, -> { where(state: [1,3,4,6]) }

  aasm column: :state, enum: true do
    state :unpay
    state :payed
    state :shiped
    state :signed
    state :completed
    state :closed

    event :pay, after_enter: :after_payed do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped
    end
    event :sign do
      transitions from: [:payed, :shiped], to: :signed
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :signed, to: :completed
    end
  end

  def delivery
    errors.add(:express_name) if express_name.blank?
    errors.add(:ship_number)  if ship_number.blank?
    return false if errors.present?
    ActiveRecord::Base.transaction do
      order.update!(express_id: express_id, ship_number: ship_number)
      order.ship!
      ship!
    end
  rescue Exception => e
    Rails.logger.info e.message
    Rails.logger.info e.backtrace.join("\n")
    errors.add(:base, e.message)
    false
  end

  def cancle
    close! && order.close!
  end

  private
  def set_default_values
    assign_attributes(seller_id: order.seller_id, supplier_id: order.supplier_id)
  end

  def after_payed
    self.paid_at = Time.current
    self.pay_amount ||= order_items.joins(:product_inventory).sum("product_inventories.cost_price")
  end
end
