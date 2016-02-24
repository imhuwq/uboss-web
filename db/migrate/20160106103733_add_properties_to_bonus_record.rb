class AddPropertiesToBonusRecord < ActiveRecord::Migration
  def change
    add_column :bonus_records, :properties, :jsonb, default: {}
  end
end
