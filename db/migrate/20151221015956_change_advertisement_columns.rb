class ChangeAdvertisementColumns < ActiveRecord::Migration
  def change
    remove_column :products, :show_advertisement_at, :datetime
    remove_column :products,  :show_advertisement, :boolean,  default: true
    remove_column :categories,  :show_advertisement, :boolean,  default: true
    remove_column :categories,  :show_advertisement_at,  :datetime
    remove_column :categories,  :use_in_store, :boolean,  default: true
    remove_column :categories,  :use_in_store_at, :boolean,  default: true

    add_column :platform_advertisements, :order_number, :integer
    add_column :platform_advertisements, :user_id, :integer
    add_column :platform_advertisements, :zone, :integer
    add_column :platform_advertisements, :product_id, :integer
    add_column :platform_advertisements, :category_id, :integer
    add_column :platform_advertisements, :platform_advertisement, :boolean, default: false

    rename_table :platform_advertisements, :advertisements
  end
end
