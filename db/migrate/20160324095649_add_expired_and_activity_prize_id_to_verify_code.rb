class AddExpiredAndActivityPrizeIdToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :expired, :boolean, default: false
    add_column :verify_codes, :activity_prize_id, :integer
    remove_column :activity_prizes, :verify_code_id, :integer
  end
end
