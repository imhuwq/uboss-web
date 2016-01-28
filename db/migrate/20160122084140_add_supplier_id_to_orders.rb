class AddSupplierIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :supplier_id, :integer
  end
end
