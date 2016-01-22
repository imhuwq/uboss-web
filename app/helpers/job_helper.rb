module JobHelper

    def reorder_user_product(user_id)
		ActiveRecord::Base.connection.execute <<-SQL.squish!
		    DROP TABLE IF EXISTS tb;
		    create table tb (product_id int, 数量排名 int, 综合排名 int);
		    insert into tb
		        with T as(select id as product_id,Row_Number() over(order by sales_amount desc) as 数量排名,
		               Row_Number() over(order by published_at desc) as 创建时间排名,
		               Row_Number() over(order by sales_amount desc)+Row_Number() over(order by published_at desc) as 排名相加
		               FROM  products
		               WHERE products.user_id = '#{user_id}'
		               )
		        select product_id, 数量排名, Row_Number() over(order by 排名相加) as 综合排名  from T;


		    UPDATE products SET comprehensive_order = tb.综合排名, sales_amount_order = tb.数量排名
		    FROM tb
		    WHERE products.id = tb.product_id;

		    drop table tb;
		SQL
	end
end
