module Admin::CarriageTemplatesHelper

  def total_carriage(carriage_template_id, count, province)
    carriage_template = CarriageTemplate.find(carriage_template_id)
    template = find_template_by_address(carriage_template, province)
    calculate_price(count, template)
  end

  def calculate_price(count, template)
    balance = count - template.first_item
    extend_count = balance > 0 ? balance : 0

    template.carriage + extend_count * template.extend_carriage
  end

  #address is provinces name
  def find_template_by_address(carriage_template, address)
    different_areas = carriage_template.different_areas

    area = different_areas.joins(:regions).where(regions: {name: address}).first
    area = different_areas.joins(:regions).where(regions: {name: '其他'}).first if area.blank?
    area
  end

  def find_all_templates(items, province)
    templates = []
    items.each do |item|
      templates.push(find_template_by_address(item.product.carriage_template, province))
    end
    templates
  end

  def carriage_way(template, count)
    extend_price = count.to_f / template.extend_item.to_f
    template.extend_carriage * ( extend_price < 1 ? 0 : extend_price )
  end

  #{ 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }
  def unify_transportation_way(items)
    items1 = items.select{ |item| item.product.transportation_way == 1 }
  end

  def template_transportation_way(items)
    items2 = items.select{ |item| item.product.transportation_way == 2 }
  end

  def max_traffic_expense(items1)
    items1.map { |item| item.product.traffic_expens }.max
  end

  def carriage_template_group_by(items2)
    items2.group_by{ |item| item.product.carriage_template_id }
  end

  def uniq_carriage_template(items2)
    uniq_items = []
    carriage_template_group_by(items2).each do |carriage_template_id, items|
      uniq_items.push(items.first)
    end
  end


  # items:  order_items || cart_items
  def calculate_ship_price(items, user_address)
    province = ChinaCity.get(user_address.province)
    items1 = unify_transportation_way(items)
    items2 = template_transportation_way(items)
    max_traffic = max_traffic_expense(items1)
    carriage_template_group = uniq_carriage_template(items2)
    templates = find_all_templates(carriage_template_group, province)

    max_carriage_expense = templates.order('carriage desc').order('extend_carriage asc').first

    if max_traffic >= max_carriage_expense.carriage && max_carriage_expense.extend_carriage > 0
      ship_price = max_traffic
    else
      items2.pop(max_carriage_expense)
      ship_price = max_traffic + max_carriage_expense.carriage
    end

    carriage_template_group_by(items2).each do |carriage_template_id, items|   # 运费模版
      items_count = items.sum{ |item| item.count }
      ship_price += carriage_way(carriage_template, items_count)
    end

    ship_price || 0.0
  end

  def sum_ship_price(cart_items, user_address)
    sum = 0.0
    CartItem.group_by_seller(cart_items).each do |seller, cart_item|
      sum += calculate_ship_price(cart_item, user_address)
    end
    sum
  end

  def calculate_product_ship_price(product, count, user_address)
    if product.transportation_way == 1
      product.traffic_expense.to_f
    elsif product.transportation_way == 2 && user_address.try(:province)
      province = ChinaCity.get(user_address.province)
      total_carriage(product.carriage_template_id, count, province)
    else
      0.0
    end
  end

end
