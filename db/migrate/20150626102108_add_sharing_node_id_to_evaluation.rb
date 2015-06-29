class AddSharingNodeIdToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :sharing_node_id, :integer
  end
end
