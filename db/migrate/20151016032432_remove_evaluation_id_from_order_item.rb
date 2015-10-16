class RemoveEvaluationIdFromOrderItem < ActiveRecord::Migration
  def change
    remove_column :order_items, :evaluation_id, :integer
  end
end
