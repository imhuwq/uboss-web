class CreateUserRoleRelations < ActiveRecord::Migration
  def change
    create_table :user_role_relations do |t|
      t.integer :user_id
      t.integer :user_role_id
    end
  end
end
