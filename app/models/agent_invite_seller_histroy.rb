class AgentInviteSellerHistroy < ActiveRecord::Base

  validates_presence_of :agent_id
  validates_uniqueness_of :mobile

  enum status: { invited: 0, bind: 1, authenticated: 2 }

  def self.find_or_new_by_mobile(mobile)
    histroy = self.find_or_create_by(mobile: mobile)
    histroy.set_expire_time
    histroy.generate_code
    histroy
  end

  def generate_code #生成邀请码
    loop do
      self.invite_code = SecureRandom.hex 4
      break if !AgentInviteSellerHistroy.find_by(invite_code: invite_code)
    end
  end

  def set_expire_time # 设定过期时间
    self.expire_at = DateTime.now + 1.day
  end

  def expired?
    expire_at.present? ? self.expire_at < DateTime.now : false
  end
end
