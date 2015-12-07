namespace :order_db do
  desc 'init orders type'
  task init_order_type: :environment do
    puts '开始初始化订单类型'

    Order.where(type: nil).each do |order|
      unless order.update_attributes(type: "OrdinaryOrder")
        puts "订单##{order.id} 初始化失败 --- #{order.errors.full_messages.join('、')}"
      end
    end

    puts '初始化订单类型完毕!'
  end
end
