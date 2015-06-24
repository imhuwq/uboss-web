class AddFrozenIncomeToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :frozen_income, :float, default: 0
  end
end
