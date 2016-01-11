class ChangeOrderColumnsOfProducts < ActiveRecord::Migration
  def change
    remove_column :products, :sales_amount_order, :integer
    remove_column :products, :published_at_order, :integer
    add_column :products, :sales_amount, :integer, default: 0
    drop_table :statistics do |t|
      t.string   :content_type
      t.string   :resource_type, limit: 50
      t.integer  :resource_id
      t.integer  :integer_count
      t.decimal  :decimal_count
      t.jsonb    :resource_message
      t.timestamps null: false
    end
  end
end
