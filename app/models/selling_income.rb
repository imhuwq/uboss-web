class SellingIncome < ActiveRecord::Base

  validates :order_id, :user_id, :amount, presence: true

  after_create :increase_seller_income

  private

  def increase_seller_income
    UserInfo.update_counters(user.find_or_create_user_info.id, seller_income: amount)
  end

end
