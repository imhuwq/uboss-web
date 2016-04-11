module ChargeService extend self

  SITE_NAME = 'UBOSS'.freeze
  WX_JS_TRADETYPE = 'JSAPI'.freeze
  WX_NATIVE_TRADETYPE = 'NATIVE'.freeze

  class WrongWxTradeType < StandardError; ;end

  def find_or_create_charge(orders, options)
    validate_options(options)

    order_charge = find_or_create_order_charge_for_orders(orders, options)

    if !order_charge.wx_prepay_valid?
      refresh_order_wx_charge(order_charge, options)
    else
      order_charge
    end
  end

  def create_bill_charge(options)
    validate_options(options)

    weixin_openid = options[:weixin_openid]
    user = options.fetch(:user) do
      User.find_by(weixin_openid: weixin_openid)
    end
    seller = options.fetch(:service_store).user

    bill_order   = BillOrder.create!(
      user: user,
      seller: seller,
      weixin_openid: options[:weixin_openid],
      pay_amount: options.fetch(:pay_amount)
    )
    order_charge = OrderCharge.create!(user: user, bill_orders: [bill_order])

    refresh_order_wx_charge(order_charge, options)
  end

  def process_paid_result(options = {})
    result = options.fetch :result
    if !$wechat_env.test?
      return false unless WxPay::Sign.verify?(result)
      return false unless result.success?
    end

    order_charge = options.fetch :order_charge do
      pay_serial_number = result["out_trade_no"]
      OrderCharge.find_by(pay_serial_number: pay_serial_number)
    end

    return false if order_charge.paid_at.present?

    order_charge.transaction do
      order_charge.update_with_wx_pay_result(result)
      order_charge.assign_paid_amount_to_order
      order_charge.orders.each { |order| order.pay! }
      order_charge.bill_orders.each { |order| order.pay! }
    end

    true
  end

  def available_pay?(orders)
    orders.map(&:available_pay?).all? { |result| result }
  end

  def request_weixin_unifiedorder_for_bill(wx_params)
    user         = User.find_by(weixin_openid: wx_params[:openid])
    bill_order   = BillOrder.create!(
      user: user,
      weixin_openid: wx_params[:openid],
      product_id: wx_params[:product_id]
    )
    order_charge = OrderCharge.create!(user: user, bill_orders: [bill_order])
    order_charge.reset_pay_serial_number
    order_charge.save(validate: false)

    pay_amount   = Rails.env.production? ? (charge.pay_amount * 100).to_i : 1

    unifiedorder = {
      body: "#{SITE_NAME}订单-#{order_charge.orders_detail.join('、')}".first(32),
      out_trade_no: order_charge.pay_serial_number,
      total_fee: pay_amount, # 需要转换为分
      spbill_create_ip: '127.0.0.1',
      notify_url: wx_notify_url,
      trade_type: 'NATIVE',
      product_id: wx_params[:product_id],
      nonce_str: SecureRandom.hex
    }

    Rails.logger.debug("unifiedorder_params: #{unifiedorder}")
    res = WxPay::Service.invoke_unifiedorder(unifiedorder)

    unifiedorder_result = {
      return_code: "SUCCESS",
      appid: WxPay.appid,
      mch_id: WxPay.mch_id,
      nonce_str: SecureRandom.hex,
    }
    if res.success?
      order_charge.update_columns(
        prepay_id: res["prepay_id"],
        wx_code_url: res["code_url"],
        wx_trade_type: res["trade_type"],
        prepay_id_expired_at: Time.current + 2.hours
      )
      unifiedorder_result.merge!(prepay_id: res['prepay_id'], result_code: 'SUCCESS')
    else
      Rails.logger.debug("set prepay_id fail: #{res}")
      unifiedorder_result.merge!(prepay_id: res['prepay_id'], result_code: 'FAIL')
    end
    sign = WxPay::Sign.generate(unifiedorder_result)
    unifiedorder_result[:sign] = sign
    unifiedorder_result
  end

  private

  def find_or_create_order_charge_for_orders(orders, options = {})
    existing_order_charges_ids = orders.pluck(:order_charge_id).uniq.compact

    if existing_order_charges_ids.size == 1
      existing_order_charge = OrderCharge.find(existing_order_charges_ids.first)

      if existing_order_charge.orders.size == orders.size &&
          existing_order_charge.wx_trade_type == options[:trade_type]
        return existing_order_charge
      end
    end

    if existing_order_charges_ids.size > 0
      close_existing_order_charges_with_ids existing_order_charges_ids
    end

    create_new_order_charges_for_orders orders
  end

  def close_existing_order_charges_with_ids(existing_order_charges_ids)
    OrderCharge.delay.check_and_close_prepay(ids: existing_order_charges_ids)
  end

  def create_new_order_charges_for_orders(orders)
    charge = OrderCharge.create! user_id: orders.first.user_id
    charge.orders = orders
    charge
  end

  # 只有当微信支付时使用到，订单一旦确认(confirm)，即进行获取
  def refresh_order_wx_charge(charge, options)
    # 重新更新支付流水号
    charge.reset_pay_serial_number
    charge.prepay_id_expired_at = Time.current + 2.hours

    if $wechat_env.test?
      charge.prepay_id = OrderCharge::FAKE_PREPAY_ID
      charge.wx_trade_type = options[:trade_type]
      Rails.logger.debug("set FAKE prepay_id: #{charge.prepay_id}")
    else
      request_weixin_unifiedorder(charge, options) do |res|
        charge.prepay_id = res["prepay_id"]
        charge.wx_code_url = res["code_url"]
        charge.wx_trade_type = res["trade_type"]
        Rails.logger.debug("set prepay_id: #{charge.prepay_id}")
      end
    end

    charge.save!(validate: false)
    charge
  end

  def request_weixin_unifiedorder(charge, options)
    pay_amount = Rails.env.production? ? (charge.pay_amount * 100).to_i : 1
    unifiedorder = {
      body: "#{SITE_NAME}订单-#{charge.orders_detail.join('、')}".first(32),
      out_trade_no: charge.pay_serial_number,
      total_fee: pay_amount, # 需要转换为分
      spbill_create_ip: options[:remote_ip] || '127.0.0.1',
      notify_url: wx_notify_url,
      trade_type: options[:trade_type] || WX_JS_TRADETYPE,
      nonce_str: SecureRandom.hex
    }
    if unifiedorder[:trade_type] == WX_JS_TRADETYPE
      unifiedorder[:openid] = options[:weixin_openid] || charge.user.weixin_openid
    end

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

  def validate_options options
    unless [WX_JS_TRADETYPE, WX_NATIVE_TRADETYPE].include? options[:trade_type]
      raise WrongWxTradeType, "Trade type #{options[:trade_type]} is not accept."
    end
  end

end
