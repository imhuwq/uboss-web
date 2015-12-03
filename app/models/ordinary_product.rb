class OrdinaryProduct < Product

  DataBuyerPay = { 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }
  FullCut = { 0 => '件', 1 => '元' }

  validates :full_cut_number, :full_cut_unit, presence: true, if: "full_cut"
  validates_numericality_of :full_cut_number, greater_than: 0, if: "full_cut"
  validate do
    if transportation_way == 1    #统一邮费
      self.errors.add(:traffic_expense, "不能小于或等于0") if traffic_expense.to_i <= 0
    elsif transportation_way == 2 #运费模板
      self.errors.add(:carriage_template, "不能为空") if carriage_template_id.blank?
    end
  end

end
