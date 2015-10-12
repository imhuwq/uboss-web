class ChangeProductInventorieColumn < ActiveRecord::Migration
  def change
    change_column :product_inventories,  :sku_attributes, :jsonb, defalut: '{}'
  end
end
