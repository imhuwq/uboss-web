module ProductsHelper

  def user_favour_product_class(product)
    'active' if current_user.favour_products.exists?(product_id: product.id)
  end

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

  def self_privilege_card?(privilege_card)
    privilege_card && current_user && privilege_card.user_id == current_user.id
  end

  def other_users_privilege_card?(privilege_card)
    privilege_card && (current_user.blank? || (current_user && privilege_card.user_id != current_user.id))
  end

  def product_privilege_price(product, privilege_card)
    product.present_price - product_privilege_amount(product, privilege_card)
  end

  def product_privilege_amount(product, privilege_card)
    if privilege_card.present?
      privilege_card.privilege_amount(product)
    else
      product.privilege_amount
    end
  end

  def get_product_seling_inventories_json(product)
    if product.new_record?
      product.product_inventories.to_json(only: [:id, :sku_attributes, :price, :count])
    elsif product.association(:product_inventories).target.present?
      product.association(:product_inventories).target.
        select { |inventory| inventory.saling }.
        to_json(only: [:id, :sku_attributes, :price, :count])
    else
      product.product_inventories.saling.select(:id, :sku_attributes, :price, :count).to_json
    end
  end
end
