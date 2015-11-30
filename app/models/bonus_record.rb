class BonusRecord < ActiveRecord::Base

  belongs_to :user

  validates :amount, money: true

  validate :limit_rate

  private

  def limit_rate
    if self.class.where('created_at > ?', Time.now.beginning_of_day).where(user_id: user_id).count >= 3
      errors[:base] << '感谢您的支持，每天红包限领三次。'
    end
  end

end
