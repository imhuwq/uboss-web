class SetPlatformServerRateTo6AndAgentServerRateTo5 < ActiveRecord::Migration
  def change
    # NOTE
    # 请在console里面去跑这个数据迁移
    # 一些没有上线的代码将会导致migrate失败
    #
    # super_admin_ids = User.joins(:user_roles).where(:user_roles=>{name: "super_admin"}).collect(&:id)
    # UserInfo.joins(:user).where(users:{agent_id: super_admin_ids}).each do |obj|
    #   obj.update_columns(service_rate: 6, service_rate_histroy: {})
    # end
    # agent_ids = User.joins(:user_roles).where(:user_roles=>{name: "agent"}).collect(&:id) - super_admin_ids
    # UserInfo.joins(:user).where(users:{agent_id: agent_ids}).each do |obj|
    #   obj.update_columns(service_rate: 5, service_rate_histroy: {})
    # end
  end
end
