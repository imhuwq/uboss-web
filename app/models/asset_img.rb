class AssetImg < ActiveRecord::Base

  include Imagable

  # has_many :children, :class_name=>'AssetImg', :foreign_key=>'parent_id'
  belongs_to :resource, polymorphic: true #指定图片的类型/对象

  mount_uploader :avatar, ImageUploader

  compatible_with_form_api_images :avatar

  def image_url(version = nil)
    avatar.url(version)
  end

end
