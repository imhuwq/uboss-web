class Ubonus::Game < BonusRecord

  validates_numericality_of :amount, less_than_or_equal_to: 6, message: '金额非法'
  validate :limit_rate

  private

  def limit_rate
    if self.class.where('created_at > ?', Time.now.beginning_of_day).where(user_id: user_id).count >= 3
      errors[:base] << '感谢您的支持，每天红包限领三次。'
    end
  end


end
