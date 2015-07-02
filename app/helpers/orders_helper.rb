module OrdersHelper

  def order_pay_path(order, options = {})
    if Rails.env.development?
      test_wxpay_path(order, options)
    else
      order_path(order, options)
    end
  end

  def sign_package
    $weixin_client.get_jssign_package(request.url)
  end

end
