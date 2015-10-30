class OrderCharge < ActiveRecord::Base

  FAKE_PREPAY_ID = 'fake-prepay-id'

  has_many :orders
  has_many :order_items, through: :orders

  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  def self.unpay?(orders)
    bool = false
    orders.each { |order| bool = true if order.unpay? }
    bool
  end

  def user
    orders[0].user
  end

  def orders_detail
    count = order_items.count
    if count > 1
      "#{order_items.first.item_product.name}等#{count}款商品"
    else
      "#{order_items.first.item_product.name}"
    end
  end

  def pay_amount
    orders.sum(:pay_amount).to_f
  end

  def orders_check_paid
    ActiveRecord::Base.transaction do
      orders.each { |order| order.check_paid }
    end
  end

  def check_paid?
    return true if paid_at.present?

    if $wechat_env.test?
      update_with_wx_pay_result(
        "total_fee" => pay_amount * 100,
        "payment" => 'wx',
        "time_end" => Time.now
      )
      true
    else
      invoke_wx_pay_cheking
    end
  end
  alias_method :paid?, :check_paid?

  def update_with_wx_pay_result(result)
    paid_amount_result = Rails.env.production? ? (BigDecimal(result["total_fee"]) / 100) : paid_amount
    self.paid_amount = paid_amount_result
    self.payment = 'wx'
    self.paid_at = result['time_end']
    self.save(validate: false)
  end

  # 判断是否有效
  def wx_prepay_valid?
    return false if prepay_id == FAKE_PREPAY_ID && !$wechat_env.test?
    prepay_id.present? && Time.current.to_i <= prepay_id_expired_at.to_i
  end

  private
  def invoke_wx_pay_cheking
    response = WxPay::Service.invoke_orderquery(
      nonce_str: SecureRandom.uuid.tr('-', ''),
      out_trade_no: pay_serial_number
    )
    if response.success? && WxPay::Sign.verify?(response) && response['trade_state'] == 'SUCCESS'
      update_with_wx_pay_result(response)
      true
    else
      false
    end
  end
end
