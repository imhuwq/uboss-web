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

  # items:  order_items || cart_items
  def calculate_ship_price(items, user_address)
    province = ChinaCity.get(user_address.province)

    items1 = items.select{ |item| item.product.transportation_way == 1 }
    items2 = items.select{ |item| item.product.transportation_way == 2 }

    ship_price = items1.map { |item| item.product.traffic_expense.to_f }.min || 0.0                     # 固定运费

    items2.group_by{ |item| item.product.carriage_template_id }.each do |carriage_template_id, items|   # 运费模版
      items_count = items.sum{ |item| item.count }
      ship_price += total_carriage(carriage_template_id, items_count, province)
    end

    ship_price
  end

end
