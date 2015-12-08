class MigrateUserBounsBenefit < ActiveRecord::Migration
  def change
    remove_column :users, :bouns_benefit
    add_column :user_infos, :bonus_benefit, :decimal, default: 0
  end
end
