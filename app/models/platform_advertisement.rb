class PlatformAdvertisement < ActiveRecord::Base

	include Imagable
	include AASM

	has_one_image autosave: true
	delegate :image_url, to: :asset_img, allow_nil: true
	delegate :avatar=, :avatar, to: :asset_img
	enum status: { hide: 0, show: 1 }

	DATA_STATUS = { hide: '隐藏', show: '显示'}

	def asset_img
		super || build_asset_img
	end
end