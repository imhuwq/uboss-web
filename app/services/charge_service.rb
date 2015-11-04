module ChargeService

  SITE_NAME = 'UBOSS'

  extend self

  def find_or_create_charge(orders, options)
    order_charge = find_or_create_order_charge_for_orders(orders)

    if !order_charge.wx_prepay_valid?
      create_or_refresh_order_wx_charge(orders, order_charge, options)
    else
      order_charge
    end
  end

  def handle_pay_notify(result)
    result = WxPay::Result[result]
    if result.success?
      pay_serial_number = result["out_trade_no"]
      order_charge = OrderCharge.find_by(pay_serial_number: pay_serial_number)
      order_charge.update_with_wx_pay_result(result)
      order_charge.orders.each { |order| order.pay! }
    end
  end

  def available_pay?(orders)
    orders.map(&:available_pay?).all? { |result| result }
  end

  private

  def find_or_create_order_charge_for_orders(orders)
    old_order_charges_ids = orders.pluck(:order_charge_id).uniq.compact

    case old_order_charges_ids.size
    when 0
      create_new_order_charges_for_orders(orders)
    when 1
      old_order_charge = OrderCharge.find(old_order_charges_ids.first)
      if old_order_charge.orders.size == orders.size
        return old_order_charge
      else
        close_old_order_charges_with_ids(old_order_charges_ids)
        create_new_order_charges_for_orders(orders)
      end
    else
      close_old_order_charges_with_ids(old_order_charges_ids)
      create_new_order_charges_for_orders(orders)
    end
  end

  def close_old_order_charges_with_ids(old_order_charges_ids)
    OrderCharge.delay.check_and_close_prepay(ids: old_order_charges_ids)
  end

  def create_new_order_charges_for_orders(orders)
    charge = OrderCharge.create! user_id: orders.first.user_id
    charge.orders = orders
    charge
  end

  # 只有当微信支付时使用到，订单一旦确认(confirm)，即进行获取
  def create_or_refresh_order_wx_charge(orders, charge, options)
    # 重新更新支付流水号
    charge.reset_pay_serial_number
    charge.prepay_id_expired_at = Time.current + 2.hours

    if $wechat_env.test?
      charge.prepay_id = OrderCharge::FAKE_PREPAY_ID
      Rails.logger.debug("set FAKE prepay_id: #{charge.prepay_id}")
    else
      request_weixin_unifiedorder(charge, options) do |res|
        charge.prepay_id = res["prepay_id"]
        charge.wx_code_url = res["code_url"]
        Rails.logger.debug("set prepay_id: #{charge.prepay_id}")
      end
    end
    charge.save

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
      trade_type: options[:trade_type] || "JSAPI",
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

end
