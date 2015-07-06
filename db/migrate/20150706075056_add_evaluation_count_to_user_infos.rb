class AddEvaluationCountToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :good, :integer, default: 0
    add_column :user_infos, :normal, :integer, default: 0
    add_column :user_infos, :bad, :integer, default: 0
  end
end
