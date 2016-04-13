class AddExpiredAtToTableNumbers < ActiveRecord::Migration
  def change
    add_column :table_numbers, :expired_at, :datetime
  end
end
