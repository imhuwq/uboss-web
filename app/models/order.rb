class Order < ActiveRecord::Base

  include AASM
  include Orderable

  belongs_to :user
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many :order_items
  has_many :order_charges

  accepts_nested_attributes_for :order_items

  validates :user, :user_address, presence: true
  validates_uniqueness_of :number, allow_blank: true

  before_save :set_info_by_user_address, on: :create
  after_create :set_number

  delegate :mobile, :regist_mobile, to: :user, prefix: :buyer

  scope :selled, -> { where("orders.state <> 0") }

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5 }
  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  aasm column: :state, enum: true, skip_validation_on_save: true do
    state :unpay
    state :payed, after_enter: :set_pay_time
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

  private

  def set_number
    update(number: "#{Time.now.to_s(:number)[2..-1]}#{user_id}#{self.id}#{rand(1000)}")
  end

  def set_info_by_user_address
    self.address = "#{user_address.province}#{user_address.city}#{user_address.country}#{user_address.street}"
    self.mobile = user_address.mobile
    self.username = user_address.username
  end

  def set_pay_time
    update_column(:pay_time, DateTime.now)
  end

end
