class AddSkuPropertiesToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :sku_properties, :string
    OrderItem.find_each do |item|
      item.update(sku_properties: item.sku_attributes_str)
    end
  end
end
