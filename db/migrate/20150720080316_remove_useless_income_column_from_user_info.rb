class RemoveUselessIncomeColumnFromUserInfo < ActiveRecord::Migration
  def up
    remove_column :user_infos, :seller_income
    remove_column :user_infos, :seller_forzen_income
    remove_column :user_infos, :agent_income
    remove_column :user_infos, :agent_forzen_income
  end

  def down
    add_column :user_infos, :seller_income, :float
    add_column :user_infos, :seller_forzen_income, :float
    add_column :user_infos, :agent_income, :float
    add_column :user_infos, :agent_forzen_income, :float
  end
end
