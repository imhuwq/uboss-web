class UserInfo < ActiveRecord::Base

  include Imagable

  belongs_to :user

  mount_uploader :store_banner_one, ImageUploader
  mount_uploader :store_banner_two, ImageUploader
  mount_uploader :store_banner_thr, ImageUploader

  compatible_with_form_api_images :store_banner_one, :store_banner_two, :store_banner_thr

end
