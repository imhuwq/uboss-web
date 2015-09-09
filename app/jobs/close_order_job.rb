class CloseOrderJob < ActiveJob::Base
  queue_as :default

  def perform
    Order.where('created_at < ?', (Time.now - 5.days)).each do |order|
      order.may_closed? && order.closed!
    end
  end

end
