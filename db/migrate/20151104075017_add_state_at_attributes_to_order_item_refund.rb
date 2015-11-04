class AddStateAtAttributesToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :state_at_attributes, :jsonb
    change_column :order_item_refunds, :state_at_attributes, :jsonb, defalut: {}
  end
end
