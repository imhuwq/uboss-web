class ReorderProductsJob < ActiveJob::Base

  queue_as :default

  include Loggerable

  def perform(user_id)
    logger.info("START: ReorderProducts, user_id: #{user_id}")
    begin
      JobHelper.reorder_user_product(user_id) # Rails.root + 'app/helpers/job_helper'
    rescue => exception
      logger.error("ERROR: method calling while ReorderProducts, user_id: #{user_id}, exception: #{exception}")
    end
    logger.info("DONE: ReorderProducts, user_id: #{user_id}")
  end

end
