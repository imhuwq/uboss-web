module OrdersHelper

  def order_pay_path(order, options = {})
    if Rails.env.development?
      test_wxpay_path(order, options)
    else
      order_path(order, options.merge(showwxpaytitle: 1))
    end
  end

  def total_privelege_amount(order_items)
    order_items.inject(0){ |sum, oi| sum + oi.privilege_amount*oi.amount}
  end

  def sign_package
    if params[:js_mode] == 'admin'
      {
        'appId' => '123',
        'timestamp' => Time.now.to_i,
        'nonceStr' => '34567uinffg',
        'signature' => 'cfgyhncfghjkkhb'
      }
    else
      @sign_package ||= $weixin_client.get_jssign_package(request.url)
    end
  end
end
