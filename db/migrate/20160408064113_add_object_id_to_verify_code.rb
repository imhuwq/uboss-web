class AddObjectIdToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :target_id, :integer
  end
end
