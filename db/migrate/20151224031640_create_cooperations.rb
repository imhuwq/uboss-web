class CreateCooperations < ActiveRecord::Migration
  def change
    create_table :cooperations do |t|
      t.integer :supplier_id, index: true
      t.integer :seller_id, index: true

      t.timestamps null: false
    end
  end
end
