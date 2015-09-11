class CloseOrderJob < ActiveJob::Base
  queue_as :default

  def perform
    Order.where('created_at < ?', (Time.now - 5.days)).where(state: 'unpay').each do |order|
      order.may_close? && order.close!
    end
  end

end
