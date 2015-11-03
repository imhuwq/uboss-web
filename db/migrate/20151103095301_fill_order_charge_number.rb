class FillOrderChargeNumber < ActiveRecord::Migration
  def up
    say_with_time 'fill all order charge number' do
      OrderCharge.where(number: nil).find_each do |order_charge|
        order_charge.__send__ :set_number
        order_charge.update_column :number, order_charge.number
      end
    end
  end
end
