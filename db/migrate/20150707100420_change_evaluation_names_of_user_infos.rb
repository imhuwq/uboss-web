class ChangeEvaluationNamesOfUserInfos < ActiveRecord::Migration
  def change
    rename_column :user_infos, :good, :good_evaluation
    rename_column :user_infos, :normal, :normal_evaluation
    rename_column :user_infos, :bad, :bad_evaluation
  end
end
