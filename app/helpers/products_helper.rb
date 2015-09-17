module ProductsHelper

  def product_sharing_link(product, sharing_node=nil)
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

  def store_good_rate(seller)
    rate_data = seller.store_rates
    total = store_total_rate(seller)
    rate = if total > 0
             rate_data['good'].to_i * 100 / total
           else
             100
           end
    number_to_percentage(rate, precision: 0)
  end

  def store_total_rate(seller)
    rate_data = seller.store_rates
    rate_data.inject(0) { |r, v| r += v[1].to_i }
  end
end
