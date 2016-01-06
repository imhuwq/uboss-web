class BonusRecord < ActiveRecord::Base

  belongs_to :user
  belongs_to :bonus_resource, polymorphic: true

  validates :amount, money: true
  validates_presence_of :user, if: :user_required
  validates_presence_of :type

  after_create :increase_user_bonus_benefit, if: :directly_assign

  private

  def user_required
    true
  end

  def directly_assign
    true
  end

  def increase_user_bonus_benefit
    UserInfo.update_counters(user.user_info.id, { bonus_benefit: amount })
  end

end
