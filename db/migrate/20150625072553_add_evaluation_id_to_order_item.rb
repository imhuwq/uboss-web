class AddEvaluationIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :evaluation_id, :integer
  end
end
