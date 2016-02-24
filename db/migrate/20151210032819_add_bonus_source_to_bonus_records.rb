class AddBonusSourceToBonusRecords < ActiveRecord::Migration
  def change
    add_reference :bonus_records, :bonus_resource, polymorphic: true
  end
end
