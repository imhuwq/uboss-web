class AddEvaluationCountToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :good, :integer
    add_column :user_infos, :normal, :integer
    add_column :user_infos, :bad, :integer
  end
end
