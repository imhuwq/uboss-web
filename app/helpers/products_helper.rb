module ProductsHelper

  def store_sharing_link(seller, sharing_node = nil)
    if sharing_node.blank?
      store_url(seller)
    else
      sharing_url(sharing_node)
    end
  end

  def product_sharing_link(product, sharing_node = nil)
    if sharing_node.blank?
      product_url(product)
    else
      sharing_url(sharing_node)
    end
  end

  def product_traffic(product)
    if @product.buyer_pay
      "￥#{@product.traffic_expense}"
    else
      '包邮'
    end
  end

  def product_sharing_title(product)
    "【#{product.name}】#{number_to_currency(product.present_price)}优惠购买，分享还能拿返利，快来UBOSS看看吧"
  end

  def product_sharing_desc(product)
    "#{product.short_description}"
  end

end
