class AddServiceRateColumnsToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :platform_service_rate, :integer, default: 0
    add_column :user_infos, :agent_service_rate, :integer, default: 0
  end
end
