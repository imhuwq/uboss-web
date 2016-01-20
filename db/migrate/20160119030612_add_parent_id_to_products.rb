class AddParentIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent_id, :integer, index: true
  end
end
