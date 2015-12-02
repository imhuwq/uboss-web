class AddDealAtToOrderItemRefunds < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :deal_at, :datetime
  end
end
