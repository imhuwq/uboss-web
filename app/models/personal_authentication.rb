class PersonalAuthentication < ActiveRecord::Base
  CODE15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/ # 15位身份证号
  CODE18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/ # 18位身份证号
  DATA_STATUS = { posted: '已提交', review: '验证中', pass: '已通过', no_pass: '未通过' }

  attr_accessor :mobile_auth_code
  mount_uploader :face_with_identity_card_img, ImageUploader
  mount_uploader :identity_card_front_img, ImageUploader

  validates :mobile, mobile: true
  validates_presence_of :name, :address, :face_with_identity_card_img, :identity_card_front_img, :mobile, :identity_card_code
  validates_uniqueness_of :identity_card_code, :mobile, :user_id
  validate :identity_card_code_regex

  belongs_to :user
  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }

  def identity_card_code_regex
    if identity_card_code =~ CODE15 || identity_card_code =~ CODE18
      return true
    else
      errors.add(:dentity_card_code, '身份证格式错误.')
    end
  end
end
