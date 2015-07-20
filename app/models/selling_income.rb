class SellingIncome < ActiveRecord::Base

  validates :order_id, :user_id, :amount, presence: true

  after_create :increase_user_income, :record_trade

  private

  def increase_user_income
    UserInfo.update_counters(user.find_or_create_user_info.id, income: amount)
  end

  def record_trade
    Transaction.create!(
      user_id: user_id,
      source: self,
      adjust_amount: amount,
      current_amount: user.income,
      trade_type: 'selling'
    )
  end

end
