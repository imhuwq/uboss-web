class Api::V1::AccountsController < ApiBaseController

  def show
    @user = current_user
    render 'api/v1/sessions/create'
  end

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

  def become_seller
    if current_user.is_seller?
      head(200)
    else
      if current_user.bind_agent(nil)
        head(200)
      else
        render_model_errors current_user
      end
    end
  end

  private

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end
end
