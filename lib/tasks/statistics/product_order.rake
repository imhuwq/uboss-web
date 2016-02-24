path = Rails.root + 'app/helpers/job_helper'
require path.to_s
include JobHelper
namespace :statistics do
    desc 'statistics product_statistics'
    task product_order: :environment do
        puts '开始统计顺序'
        User.joins(:user_roles).where('user_roles.name = ?','seller').select(:id).each do |user|
            JobHelper.reorder_user_product(user.id)
        end
        puts '统计成功!'
    end

    task count_product_sales_amount: :environment do
        puts "开始统计销量"
        User.joins(:user_roles).where('user_roles.name = ?','seller').select(:id).each do |user|
            ActiveRecord::Base.connection.execute <<-SQL.squish!
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
