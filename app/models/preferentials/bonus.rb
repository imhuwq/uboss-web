class Preferentials::Bonus < PreferentialMeasure

  validates :discount, presence: true, numericality: { less_than_or_equal_to: 0.02 }

  before_validation :set_discount, :set_amount

  after_create :decrease_source_bonus_benefit

  private

  def decrease_source_bonus_benefit
    preferential_source.class.update_counters(
      preferential_source_id,
      bonus_benefit: -self.total_amount
    )
  end

  def set_discount
    self.discount ||= BigDecimal((rand(0..20) / 1000.0).to_s)
  end

  def set_amount
    self.amount ||= self.preferential_item.total_preferential_amount * self.discount
  end

  def set_total_amount
    self.total_amount = self.amount * self.preferential_item.total_preferential_count
  end

end
