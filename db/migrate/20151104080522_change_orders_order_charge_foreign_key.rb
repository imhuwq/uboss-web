class ChangeOrdersOrderChargeForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key :orders, :order_charges
    add_foreign_key :orders, :order_charges, on_delete: :nullify
  end
end
