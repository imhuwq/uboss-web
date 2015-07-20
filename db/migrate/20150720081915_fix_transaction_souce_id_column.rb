class FixTransactionSouceIdColumn < ActiveRecord::Migration
  def up
    rename_column :transactions, :soruce_id, :source_id
  end

  def down
    rename_column :transactions, :source_id, :soruce_id
  end
end
