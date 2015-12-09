class PlatformAdvertisement < ActiveRecord::Base

	include Imagable
	has_one_image autosave: true
	delegate :image_url, to: :asset_img, allow_nil: true
	delegate :avatar=, :avatar, to: :asset_img

	def asset_img
		super || build_asset_img
	end
end