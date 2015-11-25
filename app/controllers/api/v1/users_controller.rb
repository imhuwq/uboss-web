class Api::V1::UsersController < ApiBaseController

  def show
    @user = User.find(params[:id])
  end

end
