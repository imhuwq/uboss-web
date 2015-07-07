class ChangeEvaluationNamesOfProducts < ActiveRecord::Migration
  def change
    rename_column :products, :good, :good_evaluation
    rename_column :products, :normal, :normal_evaluation
    rename_column :products, :bad, :bad_evaluation
  end
end
