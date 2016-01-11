class CreateStockMovements < ActiveRecord::Migration
  def change
    create_table :stock_movements do |t|
      t.integer     :product_inventory_id             # 关联库存
      t.references  :originator, polymorphic: true # 关联对象
      t.integer     :quantity                         # 数量
      t.integer     :action                           # 行为

      t.timestamps null: false
    end
  end
end
