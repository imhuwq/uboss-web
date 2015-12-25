class PersonalAuthentication < Certification
  include Imagable

  # FIXME 貌似没有地方用到
  attr_accessor :mobile_auth_code
  alias_attribute :identity_card_code           , :id_num
  alias_attribute :face_with_identity_card_img  , :attachment_2
  alias_attribute :identity_card_front_img      , :attachment_3

  mount_uploader :face_with_identity_card_img, ImageUploader, mount_on: :attachment_2
  mount_uploader :identity_card_front_img, ImageUploader, mount_on: :attachment_3

  compatible_with_form_api_images :face_with_identity_card_img, :identity_card_front_img

  validates_presence_of :name, :address, :mobile, :identity_card_code
  validates_uniqueness_of :identity_card_code, :user_id
  validates :identity_card_code, identity_card_code: true

end
