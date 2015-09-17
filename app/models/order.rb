class Order < ActiveRecord::Base

  include AASM
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :express
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many   :order_items
  has_one    :order_charge, autosave: true
  has_many   :divide_incomes
  has_many   :selling_incomes
  has_many   :sharing_incomes, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :user_id, :user_address_id, :seller_id, presence: true
  validates_uniqueness_of :number, allow_blank: true

  delegate :mobile, :regist_mobile, :identify,
    to: :user, prefix: :buyer
  delegate :prepay_id, :prepay_id=, :prepay_id_expired_at, :prepay_id_expired_at=,
    :pay_serial_number, :pay_serial_number=, :payment, :payment_i18n, :paid_at, :paid_amount,
    to: :order_charge, allow_nil: true

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  scope :selled, -> { where("orders.state <> 0") }

  before_create :set_info_by_user_address

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed, after_enter: [:create_privilege_card_if_none, :send_payed_sms_to_seller]
    state :shiped, after_enter: :fill_shiped_at
    state :signed, after_enter: [:fill_signed_at, :active_privilege_card]
    state :completed, after_enter: :fill_completed_at
    state :closed, after_enter: :recover_product_stock

    event :pay, after_commit: :invoke_official_agent_order_process do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped
    end
    event :sign, after_commit: :call_order_complete_handler do
      transitions from: :shiped, to: :signed
      transitions from: :payed, to: :signed, guards: :is_official_agent?
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :signed, to: :completed
    end
  end

  def order_charge
    super || build_order_charge
  end

  def paid?
    paid_at.present?
  end

  def check_paid
    return true if !unpay?

    if order_charge.paid?
      self.pay! if state == 'unpay'
      true
    else
      false
    end
  end

  def update_pay_amount
    update_column(:pay_amount, order_items.sum(:pay_amount))
  end

  def is_official_agent?
    order_items.first.product.is_official_agent?
  end

  def order_item
    @order_item ||= order_items.first || OrderItem.new
  end

  def product
    @product ||= order_item.try(:product) || Product.new
  end

  private

  def generate_number
    time_stamp = (Time.now - Time.parse('2014-12-12')).to_i
    rand_num = ((self.user_id + rand(10000)) % 100000).to_s.rjust(5, '0')
    "#{time_stamp}#{rand_num}#{SecureRandom.hex(3).upcase}"
  end

  def fill_shiped_at
    update_column(:shiped_at, Time.now)
  end

  def fill_signed_at
    update_column(:signed_at, Time.now)
  end

  def fill_completed_at
    update_column(:completed_at, Time.now)
  end

  def set_info_by_user_address
    self.address = "#{user_address}"
    self.mobile = user_address.mobile
    self.username = user_address.username
  end

  def call_order_complete_handler
    OrderPayedHandlerJob.set(wait: 5.seconds).perform_later(self)
  end

  def recover_product_stock
    order_items.each { |order_item| order_item.recover_product_stock }
  end

  def create_privilege_card_if_none
    order_items.each(&:create_privilege_card_if_none)
  end

  def send_payed_sms_to_seller
    if seller
      PostMan.send_sms(seller.login, {name: seller.identify}, 968369)
    end
  end

  def active_privilege_card
    order_items.each(&:active_privilege_card)
  end

  def invoke_official_agent_order_process
    if order_items.first.product.is_official_agent?
      OfficialAgentOrderJob.set(wait: 5.seconds).perform_later(self)
    end
  end

end
