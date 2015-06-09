class CreateUserAddresses < ActiveRecord::Migration
  def change
    create_table :user_addresses do |t|
      t.belongs_to :user
      t.string :username
      t.string :province
      t.string :city
      t.string :country
      t.string :street
      t.string :mobile

      t.timestamps null: false
    end

    add_foreign_key :user_addresses, :users
  end
end
