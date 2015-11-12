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
    if @product.transportation_way != 0
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

  def product_privilege(product, privilege_card, type)
    unless [:price, :amount].include?(type.to_sym)
      raise "product_privilege type only accept: [price, amount]"
    end
    privilege_method = "sku_privilege_#{type}"
    if product.seling_inventories.size == 1
      [__send__(privilege_method, product.seling_inventories.first, privilege_card)]
    else
      max_inventory = product.seling_inventories.max { |inventory| inventory.price }
      min_inventory = product.seling_inventories.min { |inventory| inventory.price }
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
      privilege_card.privilege_amount(product_inventory)
    else
      product_inventory.privilege_amount
    end
  end

  def product_price(product)
    product_inventories = product.seling_inventories
    if product_inventories.size == 1
      [product_inventories.first.price]
    else
      max_inventory = product_inventories.max { |inventory| inventory.price }
      min_inventory = product_inventories.min { |inventory| inventory.price }
      if max_inventory.price == min_inventory.price
        [max_inventory.price]
      else
        [min_inventory.price, max_inventory.price]
      end
    end
  end

  def get_product_seling_inventories_json(product)
    json_attributes = [
      :id, :sku_attributes, :price, :count,
      :share_amount_lv_3, :share_amount_lv_2, :share_amount_lv_1,
      :privilege_amount, :share_amount_total
    ]
    if product.new_record?
      product.product_inventories.to_json(only: json_attributes)
    elsif product.association(:product_inventories).target.present?
      product.association(:product_inventories).target.
        select { |inventory| inventory.saling }.
        to_json(only: json_attributes)
    else
      product.seling_inventories.select(json_attributes).to_json
    end
  end
end
