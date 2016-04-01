class AddSharerIdToActivityPrize < ActiveRecord::Migration
  def change
    add_column :activity_prizes, :sharer_id, :integer
  end
end
