class AddColumnToCategories < ActiveRecord::Migration
  def change
  	add_column :categories,  :use_in_store, :boolean,  default: true
  	add_column :categories,  :use_in_store_at,  :datetime
  end
end
