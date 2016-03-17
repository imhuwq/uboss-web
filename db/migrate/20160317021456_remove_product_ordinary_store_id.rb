class RemoveProductOrdinaryStoreId < ActiveRecord::Migration
  def change
    remove_column :products, :ordinary_store_id, :integer
  end
end
