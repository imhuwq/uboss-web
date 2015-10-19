class AddBestEvaluationToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :best_evaluation, :integer
    remove_column :user_infos, :normal_evaluation, :integer
  end
end
