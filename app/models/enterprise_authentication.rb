class EnterpriseAuthentication < Certification
  include Imagable

  has_many :orders, foreign_key: :seller_id, primary_key: :user_id

  alias_attribute :business_license_img                 , :attachment_1
  alias_attribute :legal_person_identity_card_end_img   , :attachment_2
  alias_attribute :legal_person_identity_card_front_img , :attachment_3
  attr_accessor :mobile_auth_code

  mount_uploader :business_license_img, ImageUploader, mount_on: :attachment_1
  mount_uploader :legal_person_identity_card_end_img, ImageUploader, mount_on: :attachment_2
  mount_uploader :legal_person_identity_card_front_img, ImageUploader, mount_on: :attachment_3

  compatible_with_form_api_images :business_license_img, :legal_person_identity_card_end_img, :legal_person_identity_card_front_img

  validates_presence_of :enterprise_name
end
