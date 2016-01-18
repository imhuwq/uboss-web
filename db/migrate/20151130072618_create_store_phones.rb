class CreateStorePhones < ActiveRecord::Migration
  def change
    create_table :store_phones do |t|
      t.string :area_code
      t.string :fixed_line
      t.string :phone_number
      t.integer :service_store_id

      t.timestamps null: false
    end
  end
end
