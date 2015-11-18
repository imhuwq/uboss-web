class FillPaidAmountToOrder < ActiveRecord::Migration
  def up
    say_with_time 'Fill order paid_amount from order_charge' do
      OrderCharge.where('paid_at IS NOT NULL').find_each do |order_charge|
        order_charge.__send__ :assign_paid_amount_to_order
      end
    end
  end
end
