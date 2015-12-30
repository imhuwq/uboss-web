class RenameSellerIdToAgencyIdInCooperations < ActiveRecord::Migration
  def change
    rename_column :cooperations, :seller_id, :agency_id
  end
end
