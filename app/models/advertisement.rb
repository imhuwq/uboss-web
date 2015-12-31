class Advertisement < ActiveRecord::Base

  include Imagable
  include AASM
  include Orderable

  belongs_to :product
  belongs_to :category

  has_one_image autosave: true

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img

  enum status: { hide: 0, show: 1 }
  enum zone: { top: 0, central: 1 }

  DATA_STATUS = { hide: '隐藏', show: '显示' }

  module PlatformAdvertisement
    DATA_ZONE = { top: '顶部', central: '中部' }
  end

  def asset_img
    super || build_asset_img
  end

  def self.platform_advertisements
    where(platform_advertisement: true)
  end

  def self.top_advertisements
    platform_advertisements.where(zone: 0)
  end

  def self.central_advertisements
    platform_advertisements.where(zone: 1)
  end
end
