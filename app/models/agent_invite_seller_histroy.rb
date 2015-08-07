class AgentInviteSellerHistroy < ActiveRecord::Base
  enum status: { invited: 0, bind: 1, authenticated: 2 }
  validates_presence_of :agent_id
  validates_uniqueness_of :mobile
end
