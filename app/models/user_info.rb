class UserInfo < ActiveRecord::Base

  include Imagable

  belongs_to :user

  has_one_image name: :store_logo, autosave: true
  # delegate :store_logo=, :avatar, to: :store_logo
  def  store_logo_url
    store_logo.try(:image_url)
  end

  # def store_logo=(file)
  #   store_logo.avatar=(file)
  # end

  mount_uploader :store_banner_one, ImageUploader
  mount_uploader :store_banner_two, ImageUploader
  mount_uploader :store_banner_thr, ImageUploader
  mount_uploader :store_cover,      ImageUploader

  compatible_with_form_api_images :store_banner_one, :store_banner_two, :store_banner_thr, :store_cover

end
