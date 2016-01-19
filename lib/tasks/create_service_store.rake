namespace :migrate do
  desc "初始化原始订单类型 type to OrdinaryOrder"
  task init_order_type: :environment do
    Order.where(type: nil).update_all(type: 'OrdinaryOrder')
    puts '初始化订单类型完毕!'
  end

  desc '初始化商品类型 type to OrdinaryProduct'
  task init_product_type: :environment do
    Product.where(type: nil).update_all(type: 'OrdinaryProduct')
    puts '初始化商品类型完毕!'
  end

  desc '初始化店铺类型 type to OrdinaryStore'
  task init_user_info_type: :environment do
    UserInfo.where(type: nil).update_all(type: 'OrdinaryStore')
    puts '初始化店铺类型完毕!'
  end

  desc '创建团购店铺 ServiceStore'
  task init_service_store: :environment do
    User.find_each do |user|
      service_store = user.service_store
      if service_store.save(validate: false)
        printf "\e[1;32m.\e[0m"
      else
        printf "\e[1;31m.\e[0m"
      end
    end

    puts '创建团购店铺完毕!'
  end
end
