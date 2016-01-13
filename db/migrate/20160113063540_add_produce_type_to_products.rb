class AddProduceTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :produce_type, :integer, default: 0
  end
end
