class ReorderProductsJob < ActiveJob::Base

  queue_as :default

  include Loggerable

  def perform(user_id)
    JobHelper.reorder_user_product(user_id) # Rails.root + 'app/helpers/job_helper'
  end

end
