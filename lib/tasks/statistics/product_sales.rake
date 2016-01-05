namespace :statistics do
  desc 'statistics product_sells'
  task product_sales: :environment do
    puts '开始统计销量'
    Product.all.each do |p|
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

    puts '统计销量成功!'
  end
end
Advertisement.joins('left join products on (products.id = advertisements.product_id)')
      .where('(product_id is not null AND products.status = 1) OR product_id is null')
      .where(user_id: current_user.id, platform_advertisement: false)
      .order('order_number')
Product.joins('left join statistics on (statistics.resource_id = products.id)').where('statistics.resource_type = ?','product').order('statistics.integer_count').first

Product.joins('left join statistics on (statistics.resource_type = "product") on (statistics.resource_id = products.id)').order('statistics.integer_count').first

Product.select('statistics where statistics.resource_type = product form "statistics"').joins('left join statistics on (statistics.resource_id = products.id)').order('statistics.integer_count').first
