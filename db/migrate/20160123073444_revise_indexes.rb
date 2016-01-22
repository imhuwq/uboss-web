class ReviseIndexes < ActiveRecord::Migration
  def change
    remove_index :supplier_store_infos, :supplier_store_id
    add_index :supplier_store_infos, :supplier_store_id, unique: true
    add_index :supplier_product_infos, :supplier_product_id, unique: true
  end
end
