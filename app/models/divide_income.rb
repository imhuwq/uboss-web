class DivideIncome < ActiveRecord::Base

  validates :user_id, :order_id, :amount, presence: true

  after_create :increase_agent_income

  private
  def increase_agent_income
    UserInfo.update_counters(user.find_or_create_user_info.id, agent_income: amount)
  end

end
