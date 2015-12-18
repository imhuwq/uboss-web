class AreaAuthentication < Certification
  include Imagable

  alias_attribute :business_license_img                 , :attachment_1
  alias_attribute :legal_person_identity_card_end_img   , :attachment_2
  alias_attribute :legal_person_identity_card_front_img , :attachment_3

  mount_uploader :attachment_1, ImageUploader
  mount_uploader :attachment_2, ImageUploader
  mount_uploader :attachment_3, ImageUploader

  compatible_with_form_api_images :attachment_1, :attachment_2, :attachment_3

  validates_presence_of :enterprise_name
end