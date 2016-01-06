class Ubonus::WeixinInviteReward < BonusRecord

  validate :properties_include_from_and_to_weixin_user_openid, :uniq_with_form_and_to_weixin_openid
  validates_numericality_of :amount, less_than_or_equal_to: 1

  before_create :fill_user
  after_create :active_with_to_wx_user

  scope :with_properties, -> (conditions) { where("properties @> ?", conditions.to_json) }

  def active_with_to_wx_user
    return true if reload.actived
    return false if self.user.blank?
    transaction do
      update(actived: true)
      UserInfo.update_counters(user.user_info.id, income: amount)
      record_trade
    end
  end

  def user_total_income
    if user.present?
      user.reload.income
    else
      self.class.with_properties(to_wx_user_id: to_wx_user_id).sum(:amount)
    end
  end

  def to_wx_user_id
    properties['to_wx_user_id']
  end

  def from_wx_user_id
    properties['from_wx_user_id']
  end

  private

  def fill_user
    self.user ||= User.find_by(weixin_openid: to_wx_user_id)
  end

  def properties_include_from_and_to_weixin_user_openid
    if properties['from_wx_user_id'].blank?
      errors.add(:base, '扫码者为空')
    end
    if properties['to_wx_user_id'].blank?
      errors.add(:base, '扫码来源为空')
    end
  end

  def uniq_with_form_and_to_weixin_openid
    if self.class.with_properties(from_wx_user_id: from_wx_user_id, to_wx_user_id: to_wx_user_id).exists?
      errors.add(:base, '已邀请')
    end
  end

  def user_required
    false
  end

  def directly_assign
    false
  end

  def record_trade
    Transaction.create!(
      user_id: user_id,
      source: self,
      adjust_amount: amount,
      current_amount: user.income,
      trade_type: 'weixin_invite_reward'
    )
  end

end
