class Ubonus::Invite < BonusRecord

  RAND_BONUS = %w(100 80 60 40 20)
  RAND_BONUS_SESSIONS_KEY = :rand_bonus_benefit

  belongs_to :inviter, class_name: 'User'

  validates_uniqueness_of :user_id, message: '您已领取此红包'

  def self.rand_benefit_for_inviting
    RAND_BONUS.sample
  end

  def self.active_by_user_id uid
    record = find_by(user_id: uid)
    record && record.active!
  end

  def inviter_uid= crypt_id
    self.inviter_id = CryptService.decrypt crypt_id
  end

  def active!
    return false if self.actived
    transaction do
      update(actived: true)
      if inviter.present?
        Ubonus::InviteReward.create(
          amount: amount,
          user: inviter,
          bonus_resource: self
        )
      end
    end
  end

end
