namespace :migrate do
  desc "初始化原始订单类型 type to OrdinaryOrder"
  task init_order_type: :environment do
    Order.where(type: nil).each do |order|
      unless order.update_attributes(type: "OrdinaryOrder")
        puts "订单##{order.id} 初始化失败 --- #{order.errors.full_messages.join('、')}"
      end
    end

    puts '初始化订单类型完毕!'
  end

  desc '初始化商品类型 type to OrdinaryProduct'
  task init_product_type: :environment do
    Product.where(type: nil).each do |product|
      unless product.update_attributes(type: "OrdinaryProduct")
        puts "商品##{product.id} 初始化失败 --- #{product.errors.full_messages.join('、')}"
      end
    end

    puts '初始化商品类型完毕!'
  end

  desc '初始化店铺类型 type to OrdinaryStore'
  task init_user_info_type: :environment do
    UserInfo.where(type: nil).each do |user_info|
      unless user_info.update_attributes(type: "OrdinaryStore")
        puts "店铺##{user_info.id} 初始化失败 --- #{user_info.errors.full_messages.join('、')}"
      end
    end

    puts '初始化店铺类型完毕!'
  end

  desc '创建团购店铺 ServiceStore'
  task init_service_store: :environment do
    User.all.each do |user|
      if user.service_store.blank?
        user.build_service_store
        puts user.save(validate: false)
      end
    end

    puts '创建团购店铺完毕!'
  end
end
