class AddUsageAndNoteAndPostCodeToUserAddresses < ActiveRecord::Migration
  def change
    add_column :user_addresses, :usage, :jsonb, default: {}
    add_column :user_addresses, :note, :string
    add_column :user_addresses, :post_code, :integer
  end
end
