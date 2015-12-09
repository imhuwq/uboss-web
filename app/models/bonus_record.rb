class BonusRecord < ActiveRecord::Base

  belongs_to :user

  validates :amount, money: true
  validates_presence_of :user, :type

  after_create :increase_user_bonus_benefit

  private

  def increase_user_bonus_benefit
    UserInfo.update_counters(user.user_info.id, { bonus_benefit: amount })
  end

end
