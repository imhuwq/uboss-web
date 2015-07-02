class AddWxPrepayToOrderCharge < ActiveRecord::Migration
  def change
    add_column :order_charges, :prepay_id, :string
    add_column :order_charges, :prepay_id_expired_at, :datetime
  end
end
