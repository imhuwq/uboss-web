class PersonalAuthentication < ActiveRecord::Base
  include AASM

  DATA_STATUS = { 'posted'=>'已提交', 'review'=> '验证中', 'pass'=> '已通过', 'no_pass'=> '未通过' }

  attr_accessor :mobile_auth_code
  mount_uploader :face_with_identity_card_img, ImageUploader
  mount_uploader :identity_card_front_img, ImageUploader

  validates :mobile, mobile: true
  validates_presence_of :name, :address, :mobile, :identity_card_code
  validates_uniqueness_of :identity_card_code, :mobile, :user_id
  validates :identity_card_code, identity_card_code: true

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
    ea = EnterpriseAuthentication.find_by(user_id: self.user_id)
    if ea.present? and ea.status == 'pass'
      #DO_NOTHING
    else
      user.authenticated = 'no'
      user.save
    end
  end

  def self.posted
    PersonalAuthentication.where(status: 0)
  end
  def self.review
    PersonalAuthentication.where(status: 1)
  end
  def self.pass
    PersonalAuthentication.where(status: 2)
  end
  def self.no_pass
    PersonalAuthentication.where(status: 3)
  end
end
