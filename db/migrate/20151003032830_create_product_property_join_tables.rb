class CreateProductPropertyJoinTables < ActiveRecord::Migration
  def change
    create_join_table :products, :product_property_values
    create_join_table :products, :product_propertys
  end
end
