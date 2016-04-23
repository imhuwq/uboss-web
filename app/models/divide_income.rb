class DivideIncome < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :order
  belongs_to :bill_order
  belongs_to :target, polymorphic: true

  validates :user_id, :amount, presence: true
  validates_presence_of :order_id, if: -> { bill_order.blank? }
  validates_presence_of :bill_order_id, if: -> { order.blank? }

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
