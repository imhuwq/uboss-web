class Preferentials::SellerBonus < PreferentialMeasure

  after_initialize :set_amount

  validates_presence_of :preferential_source
  validate :benefit_must_enough

  after_create :decrease_source_bonus_benefit

  delegate :bonus_benefit, to: :preferential_source

  def available_bonus_benefit
    @available_bonus_benefit ||= preferential_source.bonus_benefit
  end

  private

  def benefit_must_enough
    if amount > available_bonus_benefit
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
    if self.amount > available_bonus_benefit
      self.amount = available_bonus_benefit
    end
  end

  def set_total_amount
    self.total_amount = self.amount * self.preferential_item.total_preferential_count
  end

end
