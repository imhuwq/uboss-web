class AddSurplusToActivityInfos < ActiveRecord::Migration
  def change
    add_column :activity_infos, :surplus, :integer, default: 0
  end
end
