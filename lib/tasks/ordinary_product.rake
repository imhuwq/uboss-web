namespace :product_db do
  desc 'add agent role to all user'
  task init_product_type: :environment do
    puts '开始初始化商品类型'

    Product.where(type: nil).each do |product|
      unless product.update_attributes(type: "OrdinaryProduct")
        puts "商品##{product.id} 初始化失败 --- #{product.errors.full_messages.join('、')}"
      end
    end

    puts '初始化商品类型完毕!'
  end
end
