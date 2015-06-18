class Order < ActiveRecord::Base

  include AASM
  include Orderable

  belongs_to :user
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many :order_items
  has_many :order_charges

  accepts_nested_attributes_for :order_items

  validates :user_id, :user_address, presence: true
  validates_uniqueness_of :number, allow_blank: true

  before_save :set_info_by_user_address, on: :create 
  before_create :set_number

  delegate :mobile, :regist_mobile, to: :user, prefix: :buyer

  scope :selled, -> { where("orders.state <> 0") }

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5 }
  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  aasm column: :state, enum: true, skip_validation_on_save: true do
    state :unpay
    state :payed, after_enter: :call_order_payed_handler
    state :shiped
    state :signed
    state :closed

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped 
    end
    event :signed do
      transitions from: :shiped, to: :signed 
    end
    event :close do
      transitions from: :unpay, to: :closed 
    end
  end

  def paid?
    pay_time.present?
  end

  def check_paid?
    return false if self.state != 'unpay'
    order_charges.each do |order_charge|
      if order_charge.paid?
        self.update(
          payment: order_charge.charge[:channel],
          pay_time: DateTime.strptime(order_charge.charge[:time_paid].to_s,'%s')
        )
        self.pay!
        break
      end
    end
  end

  private

  def set_number
    loop do
      order_number = 
        "#{(Time.now - Time.parse('2014-12-12')).to_i}#{(self.user_id + rand(1000)) % 10000}#{SecureRandom.hex(3).upcase}"
      unless Order.find_by(number: order_number)
        self.number = order_number and break
      end
    end
  end

  def set_info_by_user_address
    self.address = "#{user_address.province}#{user_address.city}#{user_address.country}#{user_address.street}"
    self.mobile = user_address.mobile
    self.username = user_address.username
  end

  def call_order_payed_handler
    OrderPayedHandlerJob.perform_later(self)
  end

end
