class FillExistingBonusRecordType < ActiveRecord::Migration
  def up
    BonusRecord.update_all(type: 'Ubonus::Game')
  end

  def down
    BonusRecord.where(type: 'Ubonus::Game').update_all(type: nil)
  end
end
