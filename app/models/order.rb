class Order < ActiveRecord::Base

  include AASM
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many :order_items
  has_one :order_charge, autosave: true

  accepts_nested_attributes_for :order_items

  validates :user_id, :user_address_id, :seller_id, presence: true
  validates_uniqueness_of :number, allow_blank: true

  before_create :set_info_by_user_address

  delegate :mobile, :regist_mobile, :identify, to: :user, prefix: :buyer
  delegate :prepay_id, :prepay_id=, :prepay_id_expired_at, :prepay_id_expired_at=,
    :pay_serial_number, :pay_serial_number=, :payment, :payment_i18n, :paid_at,
    to: :order_charge, allow_nil: true

  scope :selled, -> { where("orders.state <> 0") }

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5 }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed
    state :shiped, after_enter: :fill_shiped_at
    state :signed, after_enter: [:fill_signed_at, :call_order_complete_handler]
    state :closed, after_enter: :recover_product_stock

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped
    end
    event :sign do
      transitions from: :shiped, to: :signed
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
  end

  def order_charge
    super || build_order_charge
  end

  def paid?
    paid_at.present?
  end

  def check_paid
    return true if state != 'unpay' && state != 'closed'

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

  def set_info_by_user_address
    self.address = "#{user_address}"
    self.mobile = user_address.mobile
    self.username = user_address.username
  end

  def call_order_complete_handler
    OrderPayedHandlerJob.perform_later(self)
  end

  def recover_product_stock
    order_items.each { |order_item| order_item.recover_product_stock }
  end

end
