class RemoveLevelIncomeColumnFromUserInfo < ActiveRecord::Migration
  def up
    remove_column :user_infos, :income_level_one
    remove_column :user_infos, :income_level_two
    remove_column :user_infos, :income_level_thr
    change_column_default :user_infos, :income, 0
    UserInfo.where(income: nil).update_all(income: 0)
  end

  def down
    add_column :user_infos, :income_level_one, :float
    add_column :user_infos, :income_level_thr, :float
    add_column :user_infos, :income_level_two, :float
  end
end
