class RemoveParentIdFromAssetImg < ActiveRecord::Migration
  def change
    remove_column :asset_imgs, :parent_id, :integer
  end
end
