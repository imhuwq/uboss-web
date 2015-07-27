class OfficialAgentOrderJob < ActiveJob::Base
  queue_as :agent_orders

  def perform(order)
    if order.order_items.first.product.is_official_agent?
      user = order.user

      User.transaction do
        user.update_attribute(:admin, true)
        if not user.user_roles.exists?(name: 'agent')
          user.user_roles << UserRole.agent
        end

        order.sign!
      end
    end
  end

end
