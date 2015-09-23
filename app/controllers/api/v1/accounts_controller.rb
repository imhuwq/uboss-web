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
    @orders = append_default_filter current_user.orders.includes(order_items: :product)
  end

  def privilege_cards
    @privilege_cards = append_default_filter current_user.privilege_cards.includes(:product)
  end

  private

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end



end
