class AddStoreIdAndStoreTypeToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :store_id, :integer
    add_column :categories, :store_type, :string
  end
end
