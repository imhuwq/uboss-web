class RemoveSupplierIdFromSupplierProductInfos < ActiveRecord::Migration
  def up
    remove_column :supplier_product_infos, :supplier_id, :integer
  end

  def down
    add_column :supplier_product_infos, :supplier_id, :integer, index: true
    add_index :supplier_product_infos, [:product_id, :supplier_id], :unique => true
  end
end
