class AddSellerIncomeAndAgentIncomeToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :seller_income, :float
    add_column :user_infos, :seller_forzen_income, :float
    add_column :user_infos, :agent_income, :float
    add_column :user_infos, :agent_forzen_income, :float
  end
end
