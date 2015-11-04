class FillUserIdToOrderCharge < ActiveRecord::Migration
  def up
    say_with_time "Fill order_charge user_id" do
      OrderCharge.find_each do |order_charge|
        order_charge.update_column :user_id, order_charge.orders.first.try(:user_id)
      end
    end
  end
end
