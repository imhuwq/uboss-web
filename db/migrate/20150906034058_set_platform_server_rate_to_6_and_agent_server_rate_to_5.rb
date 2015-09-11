class SetPlatformServerRateTo6AndAgentServerRateTo5 < ActiveRecord::Migration
  def change
    super_admin_ids = User.joins(:user_roles).where(:user_roles=>{name: "super_admin"}).collect(&:id)
    UserInfo.joins(:user).where(users:{agent_id: super_admin_ids}).each do |obj|
      obj.update(service_rate: 6, service_rate_histroy: {})
    end
    agent_ids = User.joins(:user_roles).where(:user_roles=>{name: "agent"}).collect(&:id) - super_admin_ids
    UserInfo.joins(:user).where(users:{agent_id: agent_ids}).each do |obj|
      obj.update(service_rate: 5, service_rate_histroy: {})
    end
  end
end
