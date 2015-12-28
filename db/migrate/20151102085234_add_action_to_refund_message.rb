class AddActionToRefundMessage < ActiveRecord::Migration
  def change
    add_column :refund_messages, :action, :string
  end
end
