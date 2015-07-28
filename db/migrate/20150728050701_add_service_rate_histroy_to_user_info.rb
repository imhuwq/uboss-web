class AddServiceRateHistroyToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :service_rate_histroy, :json
  end
end
