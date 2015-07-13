class AddWxPaymentInfoToWithdraw < ActiveRecord::Migration
  def change
    add_column :withdraw_records, :wx_payment_no, :string
    add_column :withdraw_records, :wx_payment_time, :string
    add_column :withdraw_records, :error_info, :string
  end
end
