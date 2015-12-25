class ChangeAdvertisementColumns < ActiveRecord::Migration
  def change
    remove_column :products, :show_advertisement_at, :datetime
    remove_column :products,  :show_advertisement, :boolean,  default: true
    remove_column :categories,  :show_advertisement, :boolean,  default: true
    remove_column :categories,  :show_advertisement_at,  :datetime
    # remove_column :categories,  :use_in_store, :boolean,  default: true
    # remove_column :categories,  :use_in_store_at, :datetime

    add_column :platform_advertisements, :order_number, :integer
    add_column :platform_advertisements, :user_id, :integer
    add_column :platform_advertisements, :zone, :integer
    add_column :platform_advertisements, :product_id, :integer
    add_column :platform_advertisements, :category_id, :integer
    add_column :platform_advertisements, :platform_advertisement, :boolean, default: false

    rename_table :platform_advertisements, :advertisements
  end

  def up
    UserInfo.all.each do |obj|
      if obj.store_banner_one_identifier && obj.recommend_resource_one_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_one_id, avatar: obj.store_banner_one.url.split('/')[-1], platform_advertisement: false)
      end
      if obj.store_banner_two_identifier && obj.recommend_resource_two_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_two_id, avatar: obj.store_banner_two.url.split('/')[-1], platform_advertisement: false)
      end
      if obj.store_banner_thr_identifier && obj.recommend_resource_thr_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_thr_id, avatar: obj.store_banner_thr.url.split('/')[-1], platform_advertisement: false)
      end
    end
  end
end
