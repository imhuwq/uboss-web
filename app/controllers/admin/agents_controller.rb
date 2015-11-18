class Admin::AgentsController < AdminController
  def index
    authorize! :manage, :agents
    @agents = UserRole.find_by(name: 'agent').users.page(params[:page] || 1)
  end

  def show
    @agent = UserRole.find_by(name: 'agent').users.find(params[:id])
    authorize! :read, @agent
    @withdraw_records = WithdrawRecord.where(user_id: @agent).page(params[:page] || 1)
  end

end
