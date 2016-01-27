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
    can [:read, :create],   WithdrawRecord, user_id: user.id
    can :new, SupplierStore, id: nil
    can :create, SupplierStore, id: nil
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
    can :manage, ServiceProduct, user_id: user.id
    can :manage, ServiceStore, user_id: user.id
    can :manage, VerifyCode, user_id: user.id
    can :manage, Evaluation, user_id: user.id
    can :manage, :income
    can [:read, :create], PersonalAuthentication, user_id: user.id
    can [:edit, :update], PersonalAuthentication, { user_id: user.id, status: %w(posted no_pass) }
    can [:read, :create], EnterpriseAuthentication, user_id: user.id
    can [:edit, :update], EnterpriseAuthentication, { user_id: user.id, status: %w(posted no_pass) }
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
    can :manage, BankCard, user_id: user.id
    can :read, Product, user_id: user.id
    can :read, ServiceProduct, user_id: user.id
    can :read, ServiceStore, user_id: user.id
    can :read, VerifyCode, user_id: user.id
    can :read, Evaluation, user_id: user.id
  end

  def grant_permissions_to_city_manager user
    can [:read, :create], CityManagerAuthentication, user_id: user.id
    can [:edit, :update], CityManagerAuthentication, { user_id: user.id, status: %w(posted no_pass) }
    can :added, CityManager, user_id: user.id
    can :revenues, CityManager, user_id: user.id
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
    can :read, ServiceProduct
    can :manage, User, { user_roles: { name: %w(seller agent offical_operating) } }
    can :manage, PersonalAuthentication
    can :manage, EnterpriseAuthentication
    can :manage, CityManagerAuthentication
    can :manage, Certification
    can :manage, :authentications
    can :manage, :platform_advertisements
    can :manage, Advertisement
    can :manage, CityManager
  end

  def grant_permissions_to_supplier user
    can :read, User, id: user.id
    can [:destroy, :edit_info, :update_info], SupplierStore, user_id: user.id
    can :read, User, cooperation: { supplier_id: user.id }
    can :read, :agencies
    can :manage, SupplierProduct, user_id: user.id
  end

  def grant_permissions_to_agency user
    can :read, User, id: user.id
    can :manage, AgencyProduct, user_id: user.id
  end

end
