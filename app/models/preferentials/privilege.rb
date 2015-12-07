class Preferentials::Privilege < PreferentialMeasure

  before_validation :set_amount

  private

  def set_amount
    self.amount = preferential_source.privilege_amount(preferential_item.product_inventory)
  end

  def set_total_amount
    self.total_amount = self.amount * self.preferential_item.total_preferential_count
  end

end
