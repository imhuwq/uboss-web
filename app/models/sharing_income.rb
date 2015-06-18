class SharingIncome < ActiveRecord::Base

  USER_LEVEL_INCOME_MAPKEYS = [
    :income_level_one,
    :income_level_two,
    :income_level_thr
  ]

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_item

  validates :user_id, :seller_id, :order_item_id, presence: true
  validates :level, inclusion: { in: 1..3 }
  validates_numericality_of :amount, greater_than: 0

  after_create :increase_user_income
  
  private
  
  def increase_user_income
    UserInfo.update_counters(user.user_info.id, user_incomes)
  end

  def user_incomes
    return @user_incomes if @user_incomes.present?
    @user_incomes = { income: amount }
    @user_incomes.merge!(USER_LEVEL_INCOME_MAPKEYS[self.leve] => amount)
  end

end
