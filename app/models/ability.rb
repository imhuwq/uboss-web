class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # for guest user (not logged in)
    if user.admin?
      begin
        grant_method = "grant_permissions_to_#{user.role_name}"
        __send__ grant_method, user
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
  end

  def grant_permissions_to_seller user
    can :manage, Order, seller_id: user.id
    can :manage, Product, user_id: user.id
    can :read, SharingIncome, seller_id: user.id
    can :read, DivideIncome, user_id: user.id
    can :read, SellingIncome, user_id: user.id
    can :read, SellingIncome, user: { agent_id: user.id }
  end

end
