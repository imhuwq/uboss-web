class AddReturnExplainToOrderItemRefunds < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :return_explain, :string
  end
end
