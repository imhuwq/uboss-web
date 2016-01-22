class CloseOrderJob < ActiveJob::Base
  queue_as :default

  def perform
    OrdinaryOrder.unpay.where('created_at < ?', (Time.now - 3.days)).find_each(batch_size: 500) do |order|
      order.transaction do
        order.may_close? && order.close!
      end
    end

    ServiceOrder.unpay.where('created_at < ?', (Time.now - 3.days)).find_each(batch_size: 500) do |order|
      order.transaction do
        order.may_close? && order.close!
      end
    end
  end

end
