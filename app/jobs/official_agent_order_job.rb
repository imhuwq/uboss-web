class OfficialAgentOrderJob < ActiveJob::Base
  queue_as :agent_orders

  def perform(order)
    return false if !order.official_agent?

    user = order.user

    User.transaction do
      user.update_attribute(:admin, true)
      if !user.is_agent?
        user.user_roles << UserRole.agent
      end
    end

    if order.order_items.size == 1 && order.may_sign?
      order.sign!
    end
  end

end
