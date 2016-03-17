class OrdinaryProduct < Product

  DataBuyerPay = { 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }
  FullCut = { 0 => '件', 1 => '元' }

  belongs_to :ordinary_store
  validates :full_cut_number, :full_cut_unit, presence: true, if: "full_cut"
  validates_numericality_of :full_cut_number, greater_than: 0, if: "full_cut"
  validate do
    if transportation_way == 1    #统一邮费
      self.errors.add(:traffic_expense, "不能小于或等于0") if traffic_expense.to_i <= 0
    elsif transportation_way == 2 #运费模板
      self.errors.add(:carriage_template, "不能为空") if carriage_template_id.blank?
    end
  end

  def calculate_ship_price(count, user_address, product_inventory_id=nil)
    return 0.0 if meet_full_cut?(count, product_inventory_id)
    if transportation_way == 1
      traffic_expense.to_f
    elsif transportation_way == 2 && user_address.try(:province)
      province = ChinaCity.get(user_address.province)
      carriage_template = CarriageTemplate.find(carriage_template_id)
      carriage_template.total_carriage(count, province)
    else
      0.0
    end
  end

  def meet_full_cut?(count, product_inventory_id)
    if self.full_cut
      OrdinaryProduct::FullCut[self.full_cut_unit] == '件' ? check_full_cut_piece(count) : check_full_cut_yuan(count, product_inventory_id)
    end
  end

  def check_full_cut_piece(count)
    count >= full_cut_number
  end

  def check_full_cut_yuan(count, product_inventory_id)
    product_inventory = ProductInventory.find(product_inventory_id) if product_inventory_id
    ( count * product_inventory.price ) >= full_cut_number
  end

end
