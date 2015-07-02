class RemoveChargeIdToOrderCharge < ActiveRecord::Migration
  def change
    remove_column :order_charges, :charge_id
  end
end
