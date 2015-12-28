class AddStateAtAttributesToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :state_at_attributes, :jsonb, null: false, default: '{}'
  end
end
