class AddBetterEvaluationToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :better_evaluation, :integer
  end
end
