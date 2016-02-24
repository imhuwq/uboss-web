class AddCarriageFullCutToProduct < ActiveRecord::Migration
  def change
    add_column :products, :full_cut, :boolean, default: false
    add_column :products, :full_cut_number, :integer
    add_column :products, :full_cut_unit, :string
  end
end
