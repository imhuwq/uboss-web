class AddServiceRateToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :service_rate, :integer, default: 5
  end
end
