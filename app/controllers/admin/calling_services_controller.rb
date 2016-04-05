class Admin::CallingServicesController < AdminController
  load_and_authorize_resource

  def index
    @calling_services = CallingService.where(user: current_user).page(params[:page] || 1)
  end

end
