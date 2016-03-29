class BillOrder < ActiveRecord::Base

  include AASM
  include Numberable

  class WrongBillInfoType < StandardError; ;end
  class BillProductInfo < Struct.new(:seller, :pay_amount)
    def valid?
      seller.present? && (pay_amount > 0)
    end
  end

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_charge

  validates_presence_of :seller, :pay_amount
  validates_presence_of :weixin_openid, if: -> { self.user.blank? }
  validates_presence_of :user, if: -> { self.weixin_openid.blank? }

  enum state: { unpay: 0, payed: 1, closed: 3 }

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

  private

  def invoke_payed_processes
    # TODO
    # divide order
    # notification
  end

end
