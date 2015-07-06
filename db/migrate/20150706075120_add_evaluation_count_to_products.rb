class AddEvaluationCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :good, :integer, default: 0
    add_column :products, :normal, :integer, default: 0
    add_column :products, :bad, :integer, default: 0
  end
end
