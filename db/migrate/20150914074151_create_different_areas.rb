class CreateDifferentAreas < ActiveRecord::Migration
  def change
    create_table :different_areas do |t|
      t.integer :carriage_template_id
      t.integer :state_id
      t.integer :first_item
      t.decimal :carriage
      t.integer :extend_item
      t.decimal :extend_carriage

      t.timestamps null: false
    end
  end
end
