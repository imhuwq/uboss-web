class PrivilegeCardsController < ApplicationController
  layout 'mobile'

  def index
    @privilege_cards = append_default_filter current_user.privilege_cards, order_column: :updated_at, page_size: 10
    render partial: 'privilege_cards/privilege_card', collection: @privilege_cards if request.xhr?
  end

  def show
    @privilege_card = current_user.privilege_cards.find(params[:id])
    @seller = @privilege_card.seller
    @favour_products = current_user.favour_products

    @products = append_default_filter @seller.products.published, order_column: :updated_at
    @hots = @seller.products.hots.recent.limit(3)
  end

  def set_privilege_rate
    if current_user.update(params.require(:user).permit(:privilege_rate))
      redirect_to edit_rate_privilege_cards_path, notice: '设置成功'
    else
      flash.now[:error] = model_errors(current_user).join('<br/>')
      render :edit_rate
    end
  end

end
