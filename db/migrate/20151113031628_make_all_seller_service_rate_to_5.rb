class MakeAllSellerServiceRateTo5 < ActiveRecord::Migration
  def up
    UserInfo.joins(:user).where.not(users: { agent_id: nil }).update_all(service_rate: 5)
  end
end
