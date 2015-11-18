class AddBestEvaluationToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :best_evaluation, :integer
    UserInfo.all.each do |user_info|
      user_info.best_evaluation = user_info.good_evaluation
      user_info.good_evaluation = user_info.normal_evaluation
      user_info.save
    end
    remove_column :user_infos, :normal_evaluation, :integer
  end
end
