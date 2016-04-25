class ChangeUserServiceRateColumn < ActiveRecord::Migration
  def up
    change_column :user_infos, :platform_service_rate, :decimal, default: 7.1
    change_column :user_infos, :agent_service_rate, :decimal, default: 0.2
    OrdinaryStore.update_all(platform_service_rate: 7.1, agent_service_rate: 0.2)
  end

  def down
    change_column :user_infos, :platform_service_rate, :integer
    change_column :user_infos, :agent_service_rate, :integer
    OrdinaryStore.update_all(platform_service_rate: 25, agent_service_rate: 25)
  end
end
