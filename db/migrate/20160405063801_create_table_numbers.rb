class CreateTableNumbers < ActiveRecord::Migration
  def change
    create_table :table_numbers do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :number
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
