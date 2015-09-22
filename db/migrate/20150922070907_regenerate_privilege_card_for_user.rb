class RegeneratePrivilegeCardForUser < ActiveRecord::Migration
  def change
    PrivilegeCard.delete_all
    Order.select(:user_id, :seller_id).group(:user_id, :seller_id).each do |order|
      PrivilegeCard.create(user_id: order.user_id, seller_id: order.seller_id, actived: true)
    end
  end
end
