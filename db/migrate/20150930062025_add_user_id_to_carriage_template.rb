class AddUserIdToCarriageTemplate < ActiveRecord::Migration
  def change
    add_column :carriage_templates, :user_id, :integer
  end
end
