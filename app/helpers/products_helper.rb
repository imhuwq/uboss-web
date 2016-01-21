module ProductsHelper

  def user_favour_product_class(product)
    'active' if current_user.favour_products.exists?(product_id: product.id)
  end

  def store_sharing_link(seller, sharing_node = nil, redirect = nil)
    if sharing_node.blank?
      store_url(seller, redirect: redirect)
    else
      sharing_url(sharing_node, redirect: redirect)
    end
  end

  def product_sharing_link(product, sharing_node = nil)
    if sharing_node.blank?
      url_of(product)
    else
      sharing_url(sharing_node)
    end
  end

  def url_of(product)
    case product.type
    when "OrdinaryProduct", "AgencyProduct" then product_url(product)
    else service_product_url(product) end
  end

  def product_traffic(product)
    if product.transportation_way != 0
      "￥#{product.traffic_expense}"
    else
      '包邮'
    end
  end

  def product_sharing_title(product)
    "【#{product.name}】#{number_to_currency(product.present_price)}优惠购买，这个优惠我給的！分享还能拿返利！"
  end

  def product_sharing_desc(product)
    "在我这儿，谁还会用市场价购买啊？"
  end

  def self_privilege_card?(privilege_card)
    privilege_card && current_user && privilege_card.user_id == current_user.id
  end

  def other_users_privilege_card?(privilege_card)
    privilege_card && (current_user.blank? || (current_user && privilege_card.user_id != current_user.id))
  end

  def product_privilege(product, privilege_card, type)
    unless [:price, :amount].include?(type.to_sym)
      raise "product_privilege type only accept: [price, amount]"
    end
    privilege_method = "sku_privilege_#{type}"
    if product.seling_inventories.size == 1
      [__send__(privilege_method, product.seling_inventories.first, privilege_card)]
    else
      max_inventory = product.max_price_inventory
      min_inventory = product.min_price_inventory
      if max_inventory.price == min_inventory.price
        [ __send__(privilege_method, max_inventory, privilege_card) ]
      else
        [
          __send__(privilege_method, min_inventory, privilege_card),
          __send__(privilege_method, max_inventory, privilege_card),
        ]
      end
    end
  end

  def sku_privilege_price(product_inventory, privilege_card)
    product_inventory.price - sku_privilege_amount(product_inventory, privilege_card)
  end

  def sku_privilege_amount(product_inventory, privilege_card)
    if privilege_card.present?
      privilege_card.amount(product_inventory)
    else
      0
      #product_inventory.privilege_amount
    end
  end

  def product_price(product)
    max_price = product.max_price
    min_price = product.min_price
    if max_price == min_price
      [max_price]
    else
      [min_price, max_price]
    end
  end

  def get_product_seling_inventories_json(product, supplier)
    json_attributes = if supplier
      [
        :id, :sku_attributes, :price, :count,
        :share_amount_lv_3, :share_amount_lv_2, :share_amount_lv_1,
        :privilege_amount, :share_amount_total,
        :cost_price, :suggest_price_lower, :suggest_price_upper,
        :sale_to_agency, :quantity
      ]
    else
      [
        :id, :sku_attributes, :price, :count,
        :share_amount_lv_3, :share_amount_lv_2, :share_amount_lv_1,
        :privilege_amount, :share_amount_total,
      ]
    end
    inventories = if product.new_record?
      product.product_inventories
    elsif product.association(:product_inventories).target.present?
      product.association(:product_inventories).target.
        select { |inventory| inventory.saling }
    else
      product.seling_inventories
    end
    inventories = inventories.to_json(only: json_attributes)
  end
end
