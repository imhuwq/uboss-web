class ReorderProductsJob < ActiveJob::Base

  queue_as :default

  include Loggerable

  def perform(product)
    JobHelper.reorder_user_product(product.id) # Rails.root + 'app/helpers/job_helper'
  end

end
