class RegeneratePrivilegeCardForUser < ActiveRecord::Migration
  def up
    say_with_time "Delete all old PrivilegeCard" do
      PrivilegeCard.delete_all
    end

    say_with_time "Regenerate PrivilegeCard with order data" do
      Order.select(:user_id, :seller_id).group(:user_id, :seller_id).each do |order|
        PrivilegeCard.create(user_id: order.user_id, seller_id: order.seller_id, actived: true)
      end
    end
  end
end
