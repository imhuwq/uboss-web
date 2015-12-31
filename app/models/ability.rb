class Ability

  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= User.new # for guest user (not logged in)
    roles = user.user_roles
    if user.admin? && roles.present?
      begin
        roles.order("id ASC").each do |role|
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
    can :manage, User
    can :manage, Transaction
    can :manage, :backend_status
  end

  def grant_permissions_to_offical_senior(user)
    senior_permissions
    financial_permissions
    can :update_service_rate, :uboss_seller
  end

  def grant_permissions_to_offical_financial(user)
    financial_permissions
  end

  def grant_permissions_to_offical_operating(user)
    operating_permissions
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
    can :manage, Category, user_id: user.id
    can :manage, BankCard, user_id: user.id
    can :manage, CarriageTemplate, user_id: user.id
    can :read, Express
    can :set_common, Express
    can :manage, OrderItemRefund, order_item: { order: { seller_id: user.id } }
    can :manage, UserAddress, user_id: user.id
  end

  def grant_permissions_to_agent user
    can :read, User, id: user.id
    can :read, User, agent_id: user.id
    can :read, :sellers
    can :read, DailyReport, user: { agent_id: user.id }
    can :read, SellingIncome, user: { agent_id: user.id }
    can :read, DivideIncome, user_id: user.id
    can :read,   WithdrawRecord, user_id: user.id
    can :create, WithdrawRecord, user_id: user.id
    can :manage, BankCard, user_id: user.id
    can :read, Product, user_id: user.id
  end

  private

  def senior_permissions
    can :manage, User
  end

  def financial_permissions
    can :manage, WithdrawRecord
    can :manage, SharingIncome
    can :manage, DivideIncome
    can :manage, DivideIncome
    can :manage, SellingIncome
    can :manage, Transaction
  end

  def operating_permissions
    can :manage, :agents
    can :read, :sellers
    can :handle, :sellers
    can :read, Order
    can :read, Product
    can :manage, User, { user_roles: { name: %w(seller agent offical_operating) } }
    can :manage, PersonalAuthentication
    can :manage, EnterpriseAuthentication
    can :manage, :authentications
    can :manage, :platform_advertisements
  end

end
