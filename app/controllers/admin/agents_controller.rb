class Admin::AgentsController < AdminController
  def index
    authorize! :manage, :agents
    @agents = append_default_filter User.agent
  end

  def show
    @agent = User.agent.find(params[:id])
    authorize! :read, @agent
    @withdraw_records = WithdrawRecord.where(user_id: @agent).page(params[:page] || 1)
  end

end
