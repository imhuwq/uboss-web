class EnterpriseAuthentication < ActiveRecord::Base
  include AASM

  DATA_STATUS = { 'posted'=>'已提交', 'review'=> '验证中', 'pass'=> '已通过', 'no_pass'=> '未通过' }

  attr_accessor :mobile_auth_code
  mount_uploader :business_license_img, ImageUploader
  mount_uploader :legal_person_identity_card_front_img, ImageUploader
  mount_uploader :legal_person_identity_card_end_img, ImageUploader

  validates :mobile, mobile: true
  validates_presence_of :enterprise_name, :address, :mobile
  validates_uniqueness_of :mobile, :user_id

  belongs_to :user
  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }

  aasm column: :status, enum: true, whiny_transitions: false do
    state :posted
    state :review
    state :pass, after_enter: :check_and_set_user_authenticated_to_yes
    state :no_pass, after_enter: :check_and_set_user_authenticated_to_no
  end

  def check_and_set_user_authenticated_to_yes
    user = User.find_by(id: self.user_id)
    if user.authenticated == 'no'
      user.authenticated = 'yes'
      user.save
    end
  end

  def check_and_set_user_authenticated_to_no
    user = User.find_by(id: self.user_id)
    ea = PersonalAuthentication.find_by(user_id: self.user_id)
    if ea.present? and ea.status == 'pass'
      #DO_NOTHING
    else
      user.authenticated = 'no'
      user.save
    end
  end

  def self.posted
    EnterpriseAuthentication.where(status: 0)
  end
  def self.review
    EnterpriseAuthentication.where(status: 1)
  end
  def self.pass
    EnterpriseAuthentication.where(status: 2)
  end
  def self.no_pass
    EnterpriseAuthentication.where(status: 3)
  end
end
