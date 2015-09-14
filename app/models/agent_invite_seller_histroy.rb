class AgentInviteSellerHistroy < ActiveRecord::Base

  validates_presence_of   :agent_id, :mobile, :invite_code
  validates_uniqueness_of :mobile,      scope: :agent_id
  validates_uniqueness_of :invite_code, scope: :agent_id

  enum status: { invited: 0, bind: 1, authenticated: 2 }

  def self.find_or_new_by_mobile_and_agent_id(mobile, agent_id)
    histroy =
      self.find_by(mobile: mobile, agent_id: agent_id) ||
      new(mobile: mobile, agent_id: agent_id)
    histroy.generate_code
    histroy.set_expire_time
    histroy
  end

  def generate_code #生成邀请码
    loop do
      self.invite_code = rand(1000000..9999999).to_s  # 七位数字符 区别user.agent_code的六位数
      break if !AgentInviteSellerHistroy.find_by(agent_id: agent_id, invite_code: invite_code)
    end
  end

  def set_expire_time # 设定过期时间
    self.expire_at = DateTime.now + 1.day
  end

  def expired?
    expire_at.present? ? self.expire_at < DateTime.now : false
  end

  def agent
    User.find_by(id: agent_id)
  end
end
