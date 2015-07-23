class Admin::AgentsController < AdminController
  def index
      @agents = UserRole.find_by(name: 'agent').users.page(params[:page] || 1)
  end

  def show
    @agent = UserRole.find_by(name: 'agent').users.find(params[:id])
  end

end
