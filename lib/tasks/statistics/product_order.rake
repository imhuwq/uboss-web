# namespace :statistics do
#   desc 'statistics product_statistics'
#   task product_order: :environment do
#     puts '开始统计'
#     User.joins(:user_roles).where('user_roles.name = ?','seller').each do |user|
#         user.products.published.each do |p|
#             count = 0
#             p.order_items.each do |order_item|
#                 if order_item.order.try(:state) == 'completed'
#                     count += order_item.amount
#                 end
#             end
#             sta = Statistic.find_or_new_by(resource_id: p.id, resource_type: 'product', content_type: 'sales_amount')
#             sta.integer_count = count
#             sta.save
#         end
#         sales_amount_order_ids = Statistic.where(resource_type: 'product').order('integer_count DESC').collect(&:resource_id)
#         i = 0
#         Product.where(id: sales_amount_order_ids).each do |p|
#             p.update(sales_amount_order: i)
#             i += 1
#         end
#         user.products.published.order('published_at DESC').each_with_index do |p,i|
#             p.update(published_at_order: i)
#         end
#     end
#     Product.published.each do |p|
#         order_number = p.sales_amount_order + p.published_at_order 
#         p.update(comprehensive_order: order_number)
#     end

#     puts '统计成功!'
#   end
# end


namespace :statistics do
    desc 'statistics product_statistics'
    task product_order: :environment do
        puts '开始统计顺序'
        User.joins(:user_roles).where('user_roles.name = ?','seller').select(:id).each do |user|
            result = ActiveRecord::Base.connection.execute <<-SQL.squish!
                DROP TABLE IF EXISTS tb;
                create table tb (product_id int, 综合排名 int);
                insert into tb
                    with T as(select id as product_id,Row_Number() over(order by sales_amount desc) as 数量排名,
                           Row_Number() over(order by published_at desc) as 创建时间排名,
                           Row_Number() over(order by sales_amount desc)+Row_Number() over(order by published_at desc) as 排名相加
                           from  products)
                    select product_id,Row_Number() over(order by 排名相加) as 综合排名  from T;


                UPDATE products SET comprehensive_order = tb.综合排名
                FROM tb
                WHERE products.id = tb.product_id;

                drop table tb;
            SQL
        end
        puts '统计成功!'
    end

    task count_product_sales_amount: :environment do
        puts "开始统计销量"
        User.joins(:user_roles).where('user_roles.name = ?','seller').select(:id).each do |user|
            result = ActiveRecord::Base.connection.execute <<-SQL.squish!
                DROP TABLE IF EXISTS tb;
                create table tb (product_id int, sales_amount int);
                insert into tb
                    with o_i as(select product_id, amount, order_id from order_items inner join orders on orders.state = 6 and order_items.user_id = '#{user.id}')
                    select product_id,count(amount) as sales_amount from o_i GROUP BY product_id;

                UPDATE products SET sales_amount = tb.sales_amount
                FROM tb
                WHERE products.user_id = '#{user.id}' AND products.id = tb.product_id;
                drop table tb;
            SQL
        end

        puts '统计成功!'
    end

end
