module OrdersHelper

  def order_pay_path(order, options = {})
    if Rails.env.development?
      test_wxpay_path(order, options)
    else
      order_path(order, options.merge(showwxpaytitle: 1))
    end
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

  def product_inventory_fullname(item)
    prop = if item.class == OrderItem
      item.sku_properties
    elsif item.class == ProductInventory
      item.sku_attributes_str
    end
    item.product.name + (prop.blank? ? "" : "(#{prop})")
  end
end
