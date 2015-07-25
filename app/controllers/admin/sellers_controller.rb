class Admin::SellersController < AdminController
  def index
    @sellers = User.where(agent_id: current_user.id).page(params[:page] || 1).per(15)
  end

end
