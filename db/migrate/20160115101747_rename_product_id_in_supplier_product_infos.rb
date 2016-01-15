class RenameProductIdInSupplierProductInfos < ActiveRecord::Migration
  def change
    remove_column :supplier_product_infos, :product_id, :integer, index: true
    add_column :supplier_product_infos, :supplier_product_id, :integer, index: true
  end
end
