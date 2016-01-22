class AddServiceProductAttrbutesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :service_type, :integer
    add_column :products, :monthes,      :integer
  end
end
