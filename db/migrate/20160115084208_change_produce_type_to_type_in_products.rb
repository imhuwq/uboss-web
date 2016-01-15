class ChangeProduceTypeToTypeInProducts < ActiveRecord::Migration
  def change
    remove_column :products, :produce_type, :integer
    add_column :products, :type, :string
  end
end
