class RemoveOrderToOrderCharges < ActiveRecord::Migration
  def up
    add_reference   :orders, :order_charge
    add_foreign_key :orders, :order_charges

    say_with_time 'Migrating old order_charge -> order_id' do
      OrderCharge.all.each do |order_charge|
        Order.where(id: order_charge.attributes['order_id']).update_all(order_charge_id: order_charge.id)
      end
    end

    remove_column :order_charges, :order_id
  end

  def down
    add_reference :order_charges, :order
    add_foreign_key :order_charges, :orders

    say_with_time 'Migrating old order_charge -> order_id' do
      Order.all.each do |order|
        OrderCharge.where(id: order.attributes['order_charge_id']).update_all(order_id: order.id)
      end
    end

    remove_column :orders, :order_charge_id

  end
end
