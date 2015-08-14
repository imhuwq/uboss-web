class DeleteUserDomainNameAndAddUserAgentCode < ActiveRecord::Migration
  def change
    remove_column :users, :domain_name
    add_column    :users, :agent_code, :integer
  end
end
