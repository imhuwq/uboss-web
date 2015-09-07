class Api::V1::AccountsController < ApiBaseController

  def update_password
    params.require(:password_confirmation)
    if current_user.update_with_password(password_params)
      head(200)
    else
      render_error :validation_failed, model_errors(current_user)
    end
  end

  def orders

  end

  private

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end



end
