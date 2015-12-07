class AddAddressToOrderItemRefunds < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :address, :string
  end
end
