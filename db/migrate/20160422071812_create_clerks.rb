class CreateClerks < ActiveRecord::Migration
  def change
    create_table :clerks do |t|
      t.integer :user_id
      t.string  :name
      t.string  :mobile

      t.timestamps null: false
    end
  end
end
