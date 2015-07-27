class OfficialAgentOrderJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    if order.order_items.first.product.is_official_agent?
      order.user.update_attribute(:admin, true)
      order.user.user_roles << UserRole.agent

      order.ship!
      order.sign!
    end
  end

end
