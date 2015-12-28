class BonusRecord < ActiveRecord::Base

  belongs_to :user
  belongs_to :bonus_resource, polymorphic: true

  validates :amount, money: true
  validates_presence_of :user, :type

  after_create :increase_user_bonus_benefit

  private

  def increase_user_bonus_benefit
    UserInfo.update_counters(user.user_info.id, { bonus_benefit: amount })
  end

end
