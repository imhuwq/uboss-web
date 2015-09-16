class RemoveRegionIdFromDifferentAreas < ActiveRecord::Migration
  def change
    remove_column :different_areas, :region_id, :integer
  end
end
