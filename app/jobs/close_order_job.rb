class CloseOrderJob < ActiveJob::Base
  queue_as :default

  def perform
    Order.unpay.where('created_at < ?', (Time.now - 10.days)).find_each(batch_size: 500) do |order|
      order.transaction do
        order.may_close? && order.close!
      end
    end
  end

end
