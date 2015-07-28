class Admin::SellersController < AdminController
  def index
    @sellers = User.where(agent_id: current_user.id).page(params[:page] || 1).per(15)
  end

  def show
    @seller = User.find_by_id(params[:id])
    @personal_authentication = PersonalAuthentication.find_by(user_id: @seller.id) || PersonalAuthentication.new
    @enterprise_authentication = EnterpriseAuthentication.find_by(user_id: @seller.id) || EnterpriseAuthentication.new
  end

end
