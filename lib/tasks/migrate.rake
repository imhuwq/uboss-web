namespace :migrate do
  desc 'Migrate none inventory product to get one'
  task :product_inventories do
    Product.where(share_rate_total: nil).update_all(share_rate_total: 0)
    Product.joins("LEFT JOIN product_inventories ON product_inventories.product_id = products.id").
      group('products.id').
      where('product_inventories.id IS NULL').each do |product|
        ProductInventory.create!(
          product_id: product.id,
          price: product.present_price,
          count: product.count,
          share_amount_total: product.share_amount_total,
          share_amount_lv_1: product.share_amount_lv_1,
          share_amount_lv_2: product.share_amount_lv_2,
          share_amount_lv_3: product.share_amount_lv_3,
          privilege_amount: product.privilege_amount,
          sku_attributes: { '其它' => '默认' }
        )
      end

    OrderItem.where(product_inventory_id: nil).all.each do |order_item|
      order_item.update_columns(product_inventory_id: order_item.product.product_inventories.first.id)
    end
  end
end
