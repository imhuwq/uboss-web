class AddServiceStoreIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :service_store_id, :integer
  end
end
