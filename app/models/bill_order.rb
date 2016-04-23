class BillOrder < ActiveRecord::Base

  include AASM
  include Numberable
  include Orderable

  class WrongBillInfoType < StandardError; ;end
  class BillProductInfo < Struct.new(:seller, :pay_amount)
    def valid?
      seller.present? && (pay_amount > 0)
    end
  end

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_charge
  has_many :bill_incomes

  scope :week, -> (time=Time.now) { payed.where(created_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { payed.where(created_at: time.beginning_of_month..time.end_of_month) }

  validates_presence_of :seller, :pay_amount
  validates_presence_of :weixin_openid, if: -> { self.user.blank? }
  validates_presence_of :user, if: -> { self.weixin_openid.blank? }

  enum state: { unpay: 0, payed: 1, closed: 3 }

  after_commit :set_user_identify, on: :create, if: -> { self.user_id.blank? }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed
    state :closed

    event :pay, after_commit: :invoke_payed_processes do
      transitions from: :unpay, to: :payed
    end
  end

  def self.generate_wx_qrcode_product_id(seller, pay_amount)
    "bill-#{seller.id}-#{pay_amount}"
  end

  def self.decode_wx_qrcode_product_id(product_id)
    id_identify, seller_id, pay_amount = product_id.split('-')

    if id_identify != 'bill'
      raise WrongBillInfoType, "Bill order wechat product_id(#{product_id}) invalid!"
    end

    BillProductInfo.new(
      User.find_by(id: seller_id),
      BigDecimal.new(pay_amount)
    )
  end

  def income
    @income ||= bill_incomes.sum(:amount)
  end

  def user_identify
    if user_id.present?
      user.identify
    else
      super
    end
  end

  def store_name
    @store_name ||= seller.service_store.store_name
  end

  def weixin_openid
    super || (user && user.weixin_openid)
  end

  def product_id=(wechat_product_id)
    bill_product_info = self.class.decode_wx_qrcode_product_id(wechat_product_id)
    self.seller = bill_product_info.seller
    self.pay_amount = bill_product_info.pay_amount
  end

  def product_id
    self.class.generate_wx_qrcode_product_id(seller, pay_amount)
  end

  def self.set_user_identify(bill_order)
    user_response = $weixin_client.user(bill_order.weixin_openid)
    if user_response.is_ok?
      bill_order.update_columns(
        user_identify: user_response.result['nickname']
      )
    end
    '微信用户'
  end

  private

  def set_user_identify
    self.class.delay.set_user_identify(self)
  end

  def invoke_payed_processes
    # divide order
    BillOrderDivideJob.set(wait: 3.seconds).perform_later(self)
    # TODO
    # notification
    BillOrderNotifyJob.set(wait: 2.seconds).perform_later(self)
  end

end
