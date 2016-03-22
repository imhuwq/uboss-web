class AddIndexForAgencyProducts < ActiveRecord::Migration
  def change
    add_index :products, [:user_id, :parent_id], unique: true
  end
end
