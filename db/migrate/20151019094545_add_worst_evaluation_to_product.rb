class AddWorstEvaluationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :worst_evaluation, :integer
    remove_column :products, :normal_evaluation, :integer
  end
end
