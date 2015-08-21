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

  def grant_permissions_to_super_admin user
    can :manage, :all
    cannot :edit, Product
    cannot :create, Product
    cannot :update, Product
    cannot :change_status, Product
  end

  def grant_permissions_to_seller user
    can :read, User, id: user.id
    can :manage, Order, seller_id: user.id
    can :manage, Product, user_id: user.id
    can :change_status, Product, user_id: user.id
    can :manage, PersonalAuthentication, user_id: user.id
    can :manage, EnterpriseAuthentication, user_id: user.id
    can :read,   WithdrawRecord, user_id: user.id
    can :create, WithdrawRecord, user_id: user.id
    can :read, SharingIncome, seller_id: user.id
    can :read, DivideIncome, user_id: user.id
    can :read, DivideIncome, order: { seller_id: user.id }
    can :read, SellingIncome, user_id: user.id
    can :manage, BankCard, user_id: user.id
  end

  def grant_permissions_to_agent user
    can :read, User, agent_id: user.id
    can :read, DailyReport, user: { agent_id: user.id }
    can :read, SellingIncome, user: { agent_id: user.id }
    can :manage, PersonalAuthentication, user_id: user.id
    can :manage, EnterpriseAuthentication, user_id: user.id
    can :read, DivideIncome, user_id: user.id
    can :read,   WithdrawRecord, user_id: user.id
    can :create, WithdrawRecord, user_id: user.id
    can :manage, :sellers
    can :manage, BankCard, user_id: user.id
  end

end
