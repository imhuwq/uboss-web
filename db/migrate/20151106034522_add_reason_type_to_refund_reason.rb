class AddReasonTypeToRefundReason < ActiveRecord::Migration
  def change
    add_column :refund_reasons, :reason_type, :string
  end
end
