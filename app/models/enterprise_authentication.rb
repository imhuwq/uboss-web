class EnterpriseAuthentication < ActiveRecord::Base

  include AASM
  include Imagable

  # FIXME 貌似没有地方用到
  attr_accessor :mobile_auth_code

  mount_uploader :business_license_img, ImageUploader
  mount_uploader :legal_person_identity_card_front_img, ImageUploader
  mount_uploader :legal_person_identity_card_end_img, ImageUploader

  compatible_with_form_api_images :business_license_img, :legal_person_identity_card_end_img, :legal_person_identity_card_front_img

  validates :mobile, mobile: true
  validates_presence_of :enterprise_name, :address, :mobile, :user_id
  validates_uniqueness_of :user_id

  belongs_to :user
  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }

  aasm column: :status, enum: true, whiny_transitions: false do
    state :posted
    state :review
    state :pass, after_enter: :check_and_set_user_authenticated_to_yes
    state :no_pass, after_enter: :check_and_set_user_authenticated_to_no
  end

  def check_and_set_user_authenticated_to_yes
    user = User.find_by(id: user_id)
    if user.authenticated == 'no'
      user.authenticated = 'yes'
      user.save
      PostMan.send_sms(user.login, {name: user.identify}, 968403) if user.login.present?
      aish = AgentInviteSellerHistroy.find_by(mobile: user.login)
      aish.update(status: 2) if aish.present? && user.agent_id == aish.agent_id
    end
  end

  def check_and_set_user_authenticated_to_no # 检查个人信息验证情况,若已经通过,则保存用户验证状态为通过;反之则设为未验证
    user = User.find_by(id: self.user_id)
    if PersonalAuthentication.where(user_id: self.user_id, status: 2).exists?
      #DO_NOTHING
    else
      user.authenticated = 'no'
      user.save
      PostMan.send_sms(user.login, {name: user.identify}, 968413) if user.login.present?
      aish = AgentInviteSellerHistroy.find_by(mobile: user.login)
      if aish.present? && user.agent_id == aish.agent_id
        aish.update(status: 1)
      elsif aish.present?
        aish.update(status: 0)
      end
    end
  end

end
