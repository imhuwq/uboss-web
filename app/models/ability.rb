class Ability
  include CanCan::Ability
  def initialize(user)
    @user ||= User.new # for guest user (not logged in)
    if user.present? and user.admin?
      grant_admin_authority
    end
  end

  private
  def grant_admin_authority
    can :manage, :all
  end

end
