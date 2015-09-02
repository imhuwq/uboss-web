class Api::V1::UsersController < ApiBaseController

  def update_password
    if @user = current_user.update_with_password(password_params)
      head(200)
    else
      render json: {message: @user.errors.full_messages}, status: :failure
    end
  end

  private

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

end
