class AddUserIdToBonusRecord < ActiveRecord::Migration
  def change
    add_reference :bonus_records, :user
    add_foreign_key :bonus_records, :users
  end
end
