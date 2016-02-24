class Preferentials::SellerBonus < PreferentialMeasure

  attr_accessor :available_bonus_benefit

  after_initialize :set_amount, :set_total_amount

  validates_presence_of :preferential_source
  validate :benefit_must_enough

  after_create :decrease_source_bonus_benefit

  delegate :bonus_benefit, to: :preferential_source

  def available_bonus_benefit
    @available_bonus_benefit ||= preferential_source.bonus_benefit
  end

  private

  def benefit_must_enough
    user_benefit = preferential_source.reload.bonus_benefit
    return false if user_benefit < 0

    if total_amount > user_benefit
      self.total_amount = user_benefit
    end
    errors.add(:amount, :invalid) if self.total_amount == 0
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
    return self.total_amount if self.total_amount.present?

    self.total_amount = self.amount * self.preferential_item.total_preferential_count
    if self.total_amount > available_bonus_benefit
      self.total_amount = available_bonus_benefit
    end
    p self.available_bonus_benefit.to_s
    self.available_bonus_benefit -= self.total_amount
    p '=' * 10
    p self.available_bonus_benefit.to_s
  end

end
