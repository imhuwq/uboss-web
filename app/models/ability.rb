class Ability

  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= User.new # for guest user (not logged in)
    roles = user.user_roles
    if user.admin? && roles.present?
      begin
        if user.being_agency
          grant_permissions_to_being_agency(user)
        else
          roles.order("id ASC").each do |role|
            begin
              grant_method = "grant_permissions_to_#{role.name}"
              __send__ grant_method, user
            rescue NoMethodError => e
              Rails.logger.error("ERROR: missing definition for #{role.name}, find me at: #{e.backtrace[0]}")
              next
            end
          end
          grant_general_permission user
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

  def grant_permissions_to_being_agency(user)
    can :read, User, id: user.id
    cannot :delivery, AgencyOrder, seller_id: user.id
    cannot :delete_agency_product, OrdinaryProduct do |op|
      op.type == "OrdinaryProduct"
    end
    can :manage, ServiceProduct, user_id: user.id
    can :manage, ServiceStore, user_id: user.id
    can :manage, VerifyCode, user_id: user.id
    can :manage, Evaluation, user_id: user.id
    can :manage, CallingNotify, user_id: user.id
    can :manage, CallingService, user_id: user.id
  end

  def grant_general_permission(user)
    can :read, User, id: user.id
    can :update, User, id: user.id
    can :manage, BankCard, user_id: user.id
    can [:read, :create],   WithdrawRecord, user_id: user.id
    can :new, SupplierStore unless user.has_supplier_store?
    can :create, SupplierStore unless user.has_supplier_store?
  end

  def grant_permissions_to_super_admin user
    can :manage, User
    can :manage, Transaction
    can :manage, :private_data do
      !Rails.env.production?
    end
    can :manage, :backend_status
    can :manage, Operator
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
    can :manage, BillOrder, seller_id: user.id
    cannot :delivery, AgencyOrder, seller_id: user.id
    can :manage, OrdinaryProduct, type: 'OrdinaryProduct', user_id: user.id
    cannot :delete_agency_product, OrdinaryProduct do |op|
      op.type == "OrdinaryProduct"
    end
    can :manage, ServiceProduct, user_id: user.id
    can :manage, DishesProduct, user_id: user.id
    can :manage, ServiceStore, user_id: user.id
    can :manage, VerifyCode, user_id: user.id
    can :manage, CallingNotify, user_id: user.id
    can :manage, CallingService, user_id: user.id
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
    cannot :manage, OrderItemRefund do |refund|
      refund.order_item.order.is_agency_order? && refund.order_item.order.supplier_id != user.id
    end
    can :read, OrderItemRefund do |refund|
      refund.order_item.order.is_agency_order? && refund.order_item.order.user_id == user.id
    end
    can :manage, UserAddress, user_id: user.id
    can :manage, PromotionActivity, user_id: user.id
    can :manage, SubAccount, user_id: user.id
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
    can :read, CallingNotify, user_id: user.id
    can :read, CallingService, user_id: user.id
    can :read, Evaluation, user_id: user.id
  end

  def grant_permissions_to_city_manager user
    can [:read, :create], CityManagerAuthentication, user_id: user.id
    can [:edit, :update], CityManagerAuthentication, { user_id: user.id, status: %w(posted no_pass) }
    can :added, CityManager, user_id: user.id
    can :revenues, CityManager, user_id: user.id
  end

  def grant_permissions_to_supplier user
    can :read, User, id: user.id
    can [:destroy, :edit_info, :update_info, :update_name, :update_short_description, :update_store_cover], SupplierStore, user_id: user.id
    can :read, :agencies
    can :new, :agency
    can :build_cooperation_with_auth_code, :agency
    can :build_cooperation_with_agency_id, :agency
    can :end_cooperation, :agency
    can :manage, SupplierProduct, user_id: user.id, type: "SupplierProduct"
    cannot :delete_agency_product, SupplierProduct do |sp|
      sp.type == "SupplierProduct"
    end
    cannot :store_or_list_supplier_product, SupplierProduct do |sp|
      sp.type == "SupplierProduct" and !sp.supplier.has_cooperation_with_agency?(user)
    end
    cannot :read, SupplierProduct do |sp|
      !sp.id.nil? and sp.type == "SupplierProduct" and !sp.supplier.has_cooperation_with_agency?(user) and sp.user_id != user.id
    end
    can :index, SupplierProduct
    can :manage, PurchaseOrder, supplier_id: user.id
    can :manage, AgencyOrder, supplier_id: user.id
    can :manage, OrderItemRefund, order_item: { order: { supplier_id: user.id } }
    can :manage, CarriageTemplate, user_id: user.id
    can :manage, UserAddress, user_id: user.id
    can :refresh_carriage_template, Product
  end

  def grant_permissions_to_agency user
    can :read, User, id: user.id
    can :manage, AgencyProduct, user_id: user.id, supplier: { cooperations: { agency_id: user.id } }
    cannot :delete_agency_product, AgencyProduct do |ap|
      ap.user_id == user.id and ap.supplier.has_cooperation_with_agency?(user)
    end
    can :delete_agency_product, AgencyProduct do |ap|
      ap.user_id == user.id and ap.parent.supplier == ap.supplier and !ap.supplier.has_cooperation_with_agency?(user) and ap.type == "AgencyProduct"
    end
    can :manage, :agency_product
    can :read, SupplierStore, supplier: { cooperations: { agency_id: user.id } }
    can :valid_agent_products, SupplierProduct
    can :read, SupplierProduct, supplier: { cooperations: { agency_id: user.id } }
    can :store_or_list_supplier_product, SupplierProduct, supplier: { cooperations: { agency_id: user.id } }
  end

  def grant_permissions_to_operator user
    can :manage, Shop
    can :manage, Clerk
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
    can :read, BillOrder
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
    can :manage, WechatAccount
    can :manage, PromotionActivity
  end

end
