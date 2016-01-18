class AddTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :type, :string
    add_index  :orders, :type
  end
end
