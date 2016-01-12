class AddSupplyStatusToSupplierProductInfos < ActiveRecord::Migration
  def change
    add_column :supplier_product_infos, :supply_status, :integer, default: 0
  end
end
