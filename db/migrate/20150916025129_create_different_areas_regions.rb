class CreateDifferentAreasRegions < ActiveRecord::Migration
  def change
    create_table :different_areas_regions, id: false do |t|
      t.integer :different_area_id
      t.integer :region_id
    end
  end
end
