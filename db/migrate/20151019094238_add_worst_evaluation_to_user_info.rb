class AddWorstEvaluationToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :worst_evaluation, :integer
  end
end
