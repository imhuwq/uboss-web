namespace :migrate do

  desc 'Migrate order_item privilege_info to preferentials_privileges'
  task order_item_preferentials: :environment do
    order_items = OrderItem.where('privilege_amount > 0 AND sharing_node_id IS NOT NULL AND created_at < ?',
                                  PreferentialMeasure.first.try(:created_at) || Time.now)

    OrderItem.transaction do
      order_items.each do |order_item|
        if order_item.privilege_amount > 0
          order_item.preferentials_privileges.create!(
            amount: order_item.privilege_amount,
            preferential_item: order_item,
            preferential_source: order_item.privilege_card
          )
        end
      end
    end
  end

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


  desc "Fix wrong paid_amount nonpro env"
  task :fix_paid_amount do
    return false if Rails.env.production?
    OrderCharge.where('paid_at IS NOT NULL').find_each do |order_charge|
      order_charge.update_column :paid_amount, order_charge.pay_amount
    end
  end

  desc "Init Express"
  task :init_express do
    comment_express = %w(EMS 顺丰快递 申通快递 韵达快递 圆通快递 中通快递 天天快递 天天快递 德邦 百世汇通)
    comment_express.each do |express|
      Express.find_or_create_by(name: express)
    end
  end

  desc "Init User rongclud token"
  task init_rongcloud_token: :environment  do
    User.where(rongcloud_token: nil).find_each do |user|
      user.find_or_create_rongcloud_token
    end
  end
end
