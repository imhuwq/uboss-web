class AddWorstEvaluationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :worst_evaluation, :integer
    Product.all.each do |product|
      product.best_evaluation = product.good_evaluation
      product.good_evaluation = product.normal_evaluation
      product.save
    end
    remove_column :products, :normal_evaluation, :integer
  end
end
