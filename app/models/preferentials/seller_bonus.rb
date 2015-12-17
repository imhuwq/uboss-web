class Preferentials::SellerBonus < PreferentialMeasure

  before_validation :set_amount

  validates_presence_of :preferential_source
  validate :benefit_must_enough

  after_create :decrease_source_bonus_benefit

  delegate :bonus_benefit, to: :preferential_source

  private

  def benefit_must_enough
    if amount > preferential_source.reload.bonus_benefit
      errors.add(:amount, :invalid)
    end
  end

  def decrease_source_bonus_benefit
    preferential_source.class.update_counters(
      preferential_source_id,
      bonus_benefit: -self.total_amount
    )
  end

  def set_amount
    self.amount ||= self.preferential_item.total_preferential_amount
  end

  def set_total_amount
    self.total_amount = self.amount * self.preferential_item.total_preferential_count
  end

end
