class Preferentials::Privilege < PreferentialMeasure

  private

  def set_total_amount
    self.total_amount = self.amount * self.preferential_item.total_preferential_count
  end

end
