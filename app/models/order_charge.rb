class OrderCharge < ActiveRecord::Base

  belongs_to :order

  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  def check_paid?
    return true if paid_at.present?

    response = WxPay::Service.invoke_orderquery(
      nonce_str: SecureRandom.uuid.tr('-', ''),
      out_trade_no: pay_serial_number
    )
    if response.success?
      update_with_wx_pay_result(response)
      true
    else
      false
    end
  end
  alias_method :paid?, :check_paid?

  def update_with_wx_pay_result(result)
    self.paid_amount = result["total_fee"]
    self.payment = 'wx'
    self.paied_at = result['time_end']
    self.save(validate: false)
  end

  # 判断是否有效
  def wx_prepay_valid?
    prepay_id.present? && Time.current.to_i <= prepay_id_expired_at.to_i
  end

end
