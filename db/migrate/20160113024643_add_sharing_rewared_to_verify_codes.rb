class AddSharingRewaredToVerifyCodes < ActiveRecord::Migration
  def change
    add_column :verify_codes, :sharing_rewared, :boolean, default: false
    add_column :verify_codes, :income,          :decimal, default: 0.0
  end
end
