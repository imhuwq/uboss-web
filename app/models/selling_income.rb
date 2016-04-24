class SellingIncome < ActiveRecord::Base
  include UserIncomeable
  include Orderable

  belongs_to :user
  belongs_to :order

  validates :order_id, :user_id, :amount, presence: true

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
      trade_type: 'selling'
    )
  end

end
