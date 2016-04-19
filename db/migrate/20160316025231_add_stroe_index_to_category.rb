class AddStroeIndexToCategory < ActiveRecord::Migration
  def change
    add_index(:categories, [:user_id, :name, :store_id], unique: true)

    remove_index(:categories, [:user_id, :name])
  end
end
