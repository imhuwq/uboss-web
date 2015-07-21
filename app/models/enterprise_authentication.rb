class EnterpriseAuthentication < ActiveRecord::Base
  belongs_to :user
  has_one :user_address
  mount_uploader :face_with_identity_card_img, ImageUploader
  mount_uploader :identity_card_front_img, ImageUploader

  validates :mobile, allow_nil: true, mobile: true

  enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }
end
