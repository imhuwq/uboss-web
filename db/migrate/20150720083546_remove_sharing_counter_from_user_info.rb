class RemoveSharingCounterFromUserInfo < ActiveRecord::Migration
  def up
    remove_column :user_infos, :sharing_counter
  end

  def down
    add_column :user_infos, :sharing_counter, :decimal
  end
end
