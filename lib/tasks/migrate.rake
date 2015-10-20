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
          sku_attributes: { '其它' => '默认' }
        )
      end
  end
end
