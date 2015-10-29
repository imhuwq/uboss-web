class OfficialAgentOrderJob < ActiveJob::Base
  queue_as :agent_orders

  def perform(order)
    if order.official_agent?
      user = order.user

      User.transaction do
        user.update_attribute(:admin, true)
        if not user.user_roles.exists?(name: 'agent')
          user.user_roles << UserRole.agent
        end

        if order.may_sign?
          order.sign!
        end
      end
    end
  end

end
