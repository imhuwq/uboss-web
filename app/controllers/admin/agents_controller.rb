class Admin::AgentsController < AdminController
  def index
    # if current_user.role_name == "super_admin"
      @agents = UserRole.find_by(name: 'agent').users.page(params[:page] || 1)
    # else
    #   flash[:notice] = "只有管理员才能查看"
    #   redirect_to root_path
    # end
  end

  def show
    @agent = UserRole.where(name: 'agent').users.find(params[:id])
  end

end
