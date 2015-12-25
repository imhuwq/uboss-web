class Certification < ActiveRecord::Base
  include AASM
  include Userdelegator
  belongs_to :user
  validates :user_id, :mobile, :presence => true
  validates :mobile, mobile: true
  validates :address,:presence => true
  validates :province_code, :city_code, presence: true

  scope :today, -> (date=Date.today) { where(['DATE(verified_at) = ?', date]) }
  scope :week, -> (time=Time.now) { where(verified_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { where(verified_at: time.beginning_of_month..time.end_of_month) }
  scope :by_city, ->(code) { where(city_code: code) }

  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }

  aasm column: :status, enum: true, whiny_transitions: false do
    state :posted
    state :review
    state :pass   , after_enter: :check_and_set_user_authenticated_to_yes
    state :no_pass, after_enter: :check_and_set_user_authenticated_to_no
    event :pass do
      transitions from: %i(posted review no_pass), to: :pass
    end

    event :reject do
      transitions from: %i(posted review pass), to: :no_pass
    end

    event :review do
      transitions from: :posted, to: :review
    end
  end

  def set_verified_at
    self.verified_at = Time.now
  end

  before_save :set_verified_at, if: -> { !new_record? && status_changed? }

  def check_and_set_user_authenticated_to_yes
    user = User.find_by(id: user_id)
    if user && user.update(authenticated: "yes")
      PostMan.send_sms(user.login, {name: user.identify}, 968403)
      aish = AgentInviteSellerHistroy.where(agent_id: user.agent_id).find_by(mobile: user.login)
      aish.update(status: 2) if aish.present?
    end
  end

  def check_and_set_user_authenticated_to_no # 检查企业信息验证情况,若已经通过,则保存用户验证状态为通过;反之则设为未验证
    user = User.find_by(id: self.user_id)
    if Certification.where(user_id: self.user_id).pass.where("type != ?", self.class.name).exists?
      #DO_NOTHING
    else
      user.authenticated = 'no'
      user.save
      PostMan.send_sms(user.login, {name: user.identify}, 968413)
      aish = AgentInviteSellerHistroy.find_by(mobile: user.login)
      if aish.present? && user.agent_id == aish.agent_id
        aish.update(status: 1)
      elsif aish.present?
        aish.update(status: 0)
      end
    end
  end
end
