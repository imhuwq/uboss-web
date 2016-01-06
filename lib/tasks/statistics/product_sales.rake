namespace :statistics do
  desc 'statistics product_statistics'
  task product_order: :environment do
    puts '开始统计'
    User.joins(:user_roles).where('user_roles.name = ?','seller').each do |user|
        user.products.published.each do |p|
            count = 0
            p.order_items.each do |order_item|
                if order_item.order.try(:state) == 'completed'
                    count += order_item.amount
                end
            end
            sta = Statistic.find_or_new_by(resource_id: p.id, resource_type: 'product', content_type: 'sales_amount')
            sta.integer_count = count
            sta.save
        end
        sales_amount_order_ids = Statistic.where(resource_type: 'product').order('integer_count DESC').collect(&:resource_id)
        i = 0
        Product.where(id: sales_amount_order_ids).each do |p|
            p.update(sales_amount_order: i)
            i += 1
        end
        user.products.published.order('published_at DESC').each_with_index do |p,i|
            p.update(published_at_order: i)
        end
    end
    Product.published.each do |p|
        order_number = p.sales_amount_order + p.published_at_order 
        p.update(comprehensive_order: order_number)
    end

    puts '统计成功!'
  end
end
