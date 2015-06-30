#矩形的资源，商品图像
require 'mime/types'
class AssetImg < ActiveRecord::Base

  attr_accessor :uploaded_data

  has_many :children, :class_name=>'AssetImg', :foreign_key=>'parent_id'
  belongs_to :resource, :polymorphic => true #指定图片的类型/对象

  mount_uploader :avatar, ImageUploader
end
