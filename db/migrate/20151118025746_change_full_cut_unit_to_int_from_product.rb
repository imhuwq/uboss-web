class ChangeFullCutUnitToIntFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :full_cut_unit,:string
    add_column :products, :full_cut_unit, :integer
  end
end
