#encoding:utf-8
#矩形的资源，商品图像
require 'mime/types'
class AssetImg < ActiveRecord::Base
  attr_accessor :uploaded_data
  has_many :children, :class_name=>'AssetImg', :foreign_key=>'parent_id'
  belongs_to :resource, :polymorphic => true #指定图片的类型/对象
  mount_uploader :avatar, AssetImgAvatarUploader

  # has_attachment :content_type => :image,
  #   :jpeg_quality=>75,
  #   :storage => :file_system,
  #   :max_size => 10.megabytes,
  #   :thumbnails => { :thumb => '103x103>', :tiny => '61x61>' },
  #   :processor => :MiniMagick, #:Rmagick
  #   :resize_to => '2000x2000>'
  #    :thumbnails => { :thumb => '140x105>' }
  # def swf_uploaded_data=(data)
  #   c_t = MIME::Types.type_for(data.original_filename).join('')
  #   c_t = 'image/jpeg' if c_t.blank?
  #   data.content_type = c_t
  #   self.uploaded_data = data
  # end
end