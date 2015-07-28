module SessionsHelper

  def super_admin?
    if current_user.user_roles.collect(&:name).include?('super_admin')
      return true
    else
      return false
    end
  end

end
