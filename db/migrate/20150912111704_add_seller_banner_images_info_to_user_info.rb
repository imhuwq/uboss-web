class AddSellerBannerImagesInfoToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :store_banner_one, :string
    add_column :user_infos, :store_banner_two, :string
    add_column :user_infos, :store_banner_thr, :string

    add_column :user_infos, :recommend_resource_one_id, :string
    add_column :user_infos, :recommend_resource_two_id, :string
    add_column :user_infos, :recommend_resource_thr_id, :string
  end
end
