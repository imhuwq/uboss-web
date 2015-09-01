class Api::V1::UsersController < ApiBaseController

  skip_before_action :authenticate_user_from_token!, :authenticate_user!, only: [:index]

  def index
    @users = User.limit(10)
  end

  def all
    @users = User.limit(2)
    render :index
  end

  def update_password
    if @user = current_user.update(password: params.fetch(:password))
      head(200)
    else
      render json: {message: @user.errors.full_messages}, status: :failure
    end
  end

end
