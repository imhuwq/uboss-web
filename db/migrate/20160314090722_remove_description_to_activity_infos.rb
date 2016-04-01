class RemoveDescriptionToActivityInfos < ActiveRecord::Migration
  def up
    remove_column :activity_infos, :description
  end

  def down
    add_column :activity_infos, :description, :string
  end
end
