class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # for guest user (not logged in)
    roles = user.user_roles
    if user.admin? && roles.present?
      begin
        roles.each do |role|
          grant_method = "grant_permissions_to_#{role.name}"
          __send__ grant_method, user
        end
        grant_general_permission user
      rescue NoMethodError
        no_permissions
      end
    else
      no_permissions
    end
  end

  private
  def no_permissions
    cannot :manage, :all
  end

  def grant_general_permission(user)
    can :read, User, id: user.id
    can :update, User, id: user.id
    can :manage, BankCard, user_id: user.id
  end

  def grant_permissions_to_super_admin user
    can :manage, :all
    cannot :edit, Product
    cannot :create, Product
    cannot :update, Product
    cannot :change_status, Product
    cannot :manage, BankCard
  end

  def grant_permissions_to_seller user
    can :read, User, id: user.id
    can :manage, Order, seller_id: user.id
    can :manage, Product, user_id: user.id
    can :manage, PersonalAuthentication, user_id: user.id
    can :manage, EnterpriseAuthentication, user_id: user.id
    can :read,   WithdrawRecord, user_id: user.id
    can :create, WithdrawRecord, user_id: user.id
    can :read, SharingIncome, seller_id: user.id
    can :read, DivideIncome, user_id: user.id
    can :read, DivideIncome, order: { seller_id: user.id }
    can :read, SellingIncome, user_id: user.id
    can :manage, BankCard, user_id: user.id
    can :manage, CarriageTemplate
    can :read, Express
    can :set_common, Express
    can :manage, OrderItemRefund
  end

  def grant_permissions_to_agent user
    can :read, User, agent_id: user.id
    can :read, DailyReport, user: { agent_id: user.id }
    can :read, SellingIncome, user: { agent_id: user.id }
    # 暂时取消agent的认证权利
    # can :manage, PersonalAuthentication, user_id: user.id
    # can :manage, EnterpriseAuthentication, user_id: user.id
    can :read, DivideIncome, user_id: user.id
    can :read,   WithdrawRecord, user_id: user.id
    can :create, WithdrawRecord, user_id: user.id
    # FIXME @dalezhang read sellers == read user，这样定义如何判断只能查看自己的商家？？
    # @yijie 获取的方式是 user.sellers,结果一定是跟自己绑定过的商家，已测试，无法访问没跟当前用户绑定的seller
    can :read, :sellers
    can :manage, BankCard, user_id: user.id
  end

end
