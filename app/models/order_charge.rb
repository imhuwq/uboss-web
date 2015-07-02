class OrderCharge < ActiveRecord::Base

  belongs_to :order

  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  def check_paid?
    true
  end
  alias_method :paid?, :check_paid?

  # 判断是否有效
  def wx_prepay_valid?
    prepay_id.present? && Time.current.to_i <= prepay_id_expired_at.to_i
  end

end
