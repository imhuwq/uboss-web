class AddIndexToCooperations < ActiveRecord::Migration
  def change
    add_index :cooperations, [:supplier_id, :agency_id], :unique => true
  end
end
