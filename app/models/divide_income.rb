class DivideIncome < ActiveRecord::Base

  belongs_to :user
  belongs_to :order

  validates :user_id, :order_id, :amount, presence: true

  after_create :increase_user_income, :record_trade

  private

  def increase_user_income
    UserInfo.update_counters(user.user_info.id, income: amount)
  end

  def record_trade
    Transaction.create!(
      user_id: user_id,
      source: self,
      adjust_amount: amount,
      current_amount: user.income,
      trade_type: 'agent'
    )
  end

end
