module ChargeService

  SITE_NAME = 'UBoss'

  extend self

  def find_or_create_charge(order, options)
    order_charge = order.order_charge
    if order_charge.new_record? || !order_charge.wx_prepay_valid?
      create_or_refresh_order_wx_charge(order, options)
    else
      order_charge
    end
  end

  def handle_pay_notify(result)
    pay_serial_number = result["out_trade_no"]
    order_charge = OrderCharge.find_by(pay_serial_number: pay_serial_number)
    order_charge.update_with_wx_pay_result(result)
    order_charge.order.pay!
  end

  private

  # 只有当微信支付时使用到，订单一旦确认(confirm)，即进行获取
  def create_or_refresh_order_wx_charge(order, options)
    # 重新更新支付流水号
    order.pay_serial_number = "#{order.number}-#{Time.current.to_i}"

    request_weixin_unifiedorder(order, options) do |res|
      order.prepay_id = res["prepay_id"]
      order.prepay_id_expired_at = Time.current + 2.hours
      Rails.logger.debug("set prepay_id: #{order.prepay_id}")
      order.save(validate: false)
    end

    order.order_charge
  end

  def request_weixin_unifiedorder(order, options)
    pay_amount = Rails.env.production? ? (order.pay_amount * 100).to_i : 1
    unifiedorder = {
      body: "#{SITE_NAME}-#{order.number}",
      out_trade_no: order.pay_serial_number,
      total_fee: pay_amount, # 需要转换为分
      spbill_create_ip: options[:remote_ip] || '127.0.0.1',
      notify_url: wx_notify_url,
      trade_type: "JSAPI",
      nonce_str: SecureRandom.hex,
      openid: order.user.weixin_openid
    }
    Rails.logger.debug("unifiedorder_params: #{unifiedorder}")
    res = WxPay::Service.invoke_unifiedorder(unifiedorder)
    if res.success?
      yield(res) if block_given?
    else
      Rails.logger.debug("set prepay_id fail: #{res}")
      nil
    end
  end

  def wx_notify_url
    "#{Rails.application.secrets.pay_host}/pay_notify/wechat_notify"
  end

  def charge_success(params)
    order = Order.find_by(number: params[:order_no])
    if params[:paid] == true
      order.pay!
    end
  end

end
