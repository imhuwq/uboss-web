class AddObjectTypeToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :target_type, :string
  end
end
