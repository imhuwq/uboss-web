class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.integer :user_id
      t.integer :operator_id, null: false
      t.string  :name
      t.string  :mobile
      t.string  :province
      t.string  :city
      t.string  :district
      t.string  :address
      t.string  :clerk_id
      t.string  :clerk_name

      t.timestamps null: false
    end
    add_index :shops, :user_id, unique: true
  end
end
