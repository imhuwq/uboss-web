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
    can :manage, Category, user_id: user.id
    can :manage, BankCard, user_id: user.id
    can :manage, CarriageTemplate
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

  def grant_permissions_to_supplier user
    can :read, User, id: user.id
    can :read, User, cooperation: { supplier_id: user.id }
    can :read, :sellers
    can :new_supplier_product, Product if user.is_supplier?
    can :create_supplier_product, Product if user.is_supplier?
    can :show_supplier_product, Product do |product|
      user.is_supplier? and product.supplier_product_info.supplier_id == user.id
    end
  end

end
