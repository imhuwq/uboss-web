class RemoveIndexFromAgencyProducts < ActiveRecord::Migration
  def up 
    remove_index :products, [:user_id, :parent_id]
  end

  def down
    add_index :products, [:user_id, :parent_id], unique: true
  end
end
