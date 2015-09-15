module Admin::CarriageTemplatesHelper

  def total_carriage(product, count, address)
    template = find_template_by_address(product.carriage_template, address)
    total = calculate_price(count, template)
  end

  def calculate_price(count, template)
    balance = count - template.first_item
    first_count = balance > 0 ? template.first_item : count
    extend_count = balance > 0 ? balance : 0

    first_count * template.carriage + extend_count * template.extend_carriage
  end

  def find_template_by_address(carriage_template, address)
    different_areas = carriage_template.different_areas
    state = State.find_by_name(address)
    other_state = State.find_by_name('其他')

    area = different_areas.where(state_id: state.id).first
    area = different_areas.where(state_id: other_state.id).first if area.blank?
  end
end
