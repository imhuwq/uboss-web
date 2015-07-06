class AddEvaluationCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :good, :integer
    add_column :products, :normal, :integer
    add_column :products, :bad, :integer
  end
end
