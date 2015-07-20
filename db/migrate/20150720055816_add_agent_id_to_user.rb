class AddAgentIdToUser < ActiveRecord::Migration

  def change
    add_column :users, :agent_id, :integer
    add_foreign_key :users, :users, column: :agent_id
  end

end
