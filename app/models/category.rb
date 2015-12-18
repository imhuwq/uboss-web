class Category < ActiveRecord::Base
	include Imagable
  belongs_to :user
  has_and_belongs_to_many :products, -> { uniq }
  has_one_image autosave: true
  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img

  # 店铺轮播图片 =>
  has_one_image name: :advertisement_img, autosave: true
  
  def  advertisement_img_url(option='')
    advertisement_img.try(:image_url,option)
  end

  def advertisement_img=(file)
    advertisement_img.avatar=(file)
  end

  def advertisement_img
    super || build_advertisement_img
  end
  # <-店铺轮播图片
  validates_presence_of :user_id, :name
  validates :name, uniqueness: { scope: :user_id, message: :exists }

  def asset_img
    super || build_asset_img
  end

end
