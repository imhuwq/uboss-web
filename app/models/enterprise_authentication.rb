class EnterpriseAuthentication < ActiveRecord::Base
  DATA_STATUS = { posted: '已提交', review: '验证中', pass: '已通过', no_pass: '未通过' }

  attr_accessor :mobile_auth_code
  mount_uploader :business_license_img, ImageUploader
  mount_uploader :legal_person_identity_card_front_img, ImageUploader
  mount_uploader :legal_person_identity_card_end_img, ImageUploader

  validates :mobile, mobile: true
  validates_presence_of :enterprise_name, :address, :business_license_img, :legal_person_identity_card_front_img,
                        :legal_person_identity_card_end_img, :mobile
  validates_uniqueness_of :mobile, :user_id

  belongs_to :user
  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }
end
