module ChargeService

  SITE_NAME = 'UBOSS'

  extend self

  def find_or_create_charge(orders, options)
    order_charge = orders.count > 1 ? create_and_clean_charge(orders) : orders[0].order_charge

    if order_charge.new_record? || !order_charge.wx_prepay_valid?
      create_or_refresh_order_wx_charge(orders, order_charge, options)
    else
      order_charge
    end
  end

  def create_and_clean_charge(orders)
    charge = OrderCharge.create!()
    orders.each do |order|
      #TODO 删除无用order_charge
      order.order_charge_id = charge.id
      order.save(validate: false)
    end
    charge
  end

  def handle_pay_notify(result)
    pay_serial_number = result["out_trade_no"]
    order_charge = OrderCharge.find_by(pay_serial_number: pay_serial_number)
    order_charge.update_with_wx_pay_result(result)
    order_charge.order.pay!
  end

  private

  # 只有当微信支付时使用到，订单一旦确认(confirm)，即进行获取
  def create_or_refresh_order_wx_charge(orders, charge, options)
    # 重新更新支付流水号
    charge.pay_serial_number = "#{orders[0].number}-#{Time.current.to_i}"
    charge.prepay_id_expired_at = Time.current + 2.hours

    if $wechat_env.test?
      charge.prepay_id = OrderCharge::FAKE_PREPAY_ID
      Rails.logger.debug("set FAKE prepay_id: #{charge.prepay_id}")
    else
      request_weixin_unifiedorder(charge, options) do |res|
        charge.prepay_id = res["prepay_id"]
        Rails.logger.debug("set prepay_id: #{charge.prepay_id}")
      end
    end
    charge.save(validate: false)

    charge
  end

  def request_weixin_unifiedorder(charge, options)
    pay_amount = Rails.env.production? ? (charge.pay_amount * 100).to_i : 1
    unifiedorder = {
      body: "#{SITE_NAME}-#{charge.pay_serial_number}",
      out_trade_no: charge.pay_serial_number,
      total_fee: pay_amount, # 需要转换为分
      spbill_create_ip: options[:remote_ip] || '127.0.0.1',
      notify_url: wx_notify_url,
      trade_type: "JSAPI",
      nonce_str: SecureRandom.hex,
      openid: charge.user.weixin_openid
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
