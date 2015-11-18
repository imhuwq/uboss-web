class AddPrivateIdToExpress < ActiveRecord::Migration
  def change
    add_column :expresses, :private_id, :integer
  end
end
