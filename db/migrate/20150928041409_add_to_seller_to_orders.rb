class AddToSellerToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :to_seller, :string
  end
end
