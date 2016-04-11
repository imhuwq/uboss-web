class AddOrderIdToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :order_id, :integer
  end
end
