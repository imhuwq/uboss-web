class AddUserIdToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :user_id, :integer
  end
end
