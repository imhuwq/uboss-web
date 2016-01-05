class CreateSupplierProductInfos < ActiveRecord::Migration
  def change
    create_table :supplier_product_infos do |t|
      t.decimal :cost_price
      t.decimal :suggest_price
      t.integer :product_id, index: true
      t.integer :supplier_id, index: true

      t.timestamps null: false
    end

    add_index :supplier_product_infos, [:product_id, :supplier_id], :unique => true
  end
end
