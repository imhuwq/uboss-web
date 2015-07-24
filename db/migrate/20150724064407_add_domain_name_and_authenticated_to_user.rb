class AddDomainNameAndAuthenticatedToUser < ActiveRecord::Migration
  def change
    add_column :users, :domain_name, :string
    add_column :users, :authenticated, :integer, default: 0
  end
end
