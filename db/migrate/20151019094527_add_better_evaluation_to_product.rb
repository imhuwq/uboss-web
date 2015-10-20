class AddBetterEvaluationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :better_evaluation, :integer
  end
end
