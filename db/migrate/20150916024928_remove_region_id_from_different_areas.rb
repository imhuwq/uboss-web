class RemoveRegionIdFromDifferentAreas < ActiveRecord::Migration
  def change
    if DifferentArea.column_names.include?('region_id')
      remove_column :different_areas, :region_id, :integer
    end
  end
end
