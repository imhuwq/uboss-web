class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name
      t.integer :numcode

      t.timestamps null: false
    end
  end
end
