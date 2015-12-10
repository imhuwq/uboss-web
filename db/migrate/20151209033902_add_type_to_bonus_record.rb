class AddTypeToBonusRecord < ActiveRecord::Migration
  def change
    add_column :bonus_records, :type, :string
  end
end
