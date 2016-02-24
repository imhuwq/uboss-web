class AssetImg < ActiveRecord::Base

  include Imagable

  belongs_to :resource, polymorphic: true, touch: true #指定图片的类型/对象

  mount_uploader :avatar, ImageUploader

  compatible_with_form_api_images :avatar

  def image_url(version = nil)
    avatar.url(version)
  end

end
