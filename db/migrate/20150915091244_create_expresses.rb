class CreateExpresses < ActiveRecord::Migration
  def change
    create_table :expresses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
