class AddRefundReasonIdToRefundMessage < ActiveRecord::Migration
  def change
    add_column :refund_messages, :refund_reason_id, :integer
  end
end
