class AddBestEvaluationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :best_evaluation, :integer
  end
end
