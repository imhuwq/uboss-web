class ReorderProductsJob < ActiveJob::Base

  queue_as :default

  include Loggerable

  def perform(user_id)
		products_id =  ActiveRecord::Base.connection.execute <<-SQL.squish!
		  select id FROM  products
		  WHERE products.user_id = '#{user_id}' AND products.type != 'ServiceProduct'
	  SQL
    logger.info("START: ReorderProducts, user_id: #{user_id},ids = #{products_id.to_a}")
    begin
      JobHelper.reorder_user_product(user_id) # Rails.root + 'app/helpers/job_helper'
    rescue => exception
      logger.error("ERROR: method calling while ReorderProducts, user_id: #{user_id}, exception: #{exception}")
    end
    logger.info("DONE: ReorderProducts, user_id: #{user_id}, last_product: #{Product.last.inspect} ")
  end

end
