class PrivilegeCardsController < ApplicationController

  before_action :authenticate_user!

  def index
    if request.xhr?
      @privilege_cards = append_default_filter current_user.privilege_cards, order_column: :updated_at, page_size: 10
      render partial: 'privilege_cards/privilege_card', collection: @privilege_cards
    else
      redirect_to account_path(anchor: 'showpcards')
    end
  end

  def show
    @privilege_card = current_user.privilege_cards.find(params[:id])
    @seller = @privilege_card.seller
    @favour_products = current_user.favoured_products.where(user_id: @seller.id, type: 'OrdinaryProduct').recent.limit(6)
    set_sharing_link_node

    @products = append_default_filter @seller.ordinary_products.published, order_column: :updated_at
    @hots = @seller.ordinary_products.hots.recent.limit(3)
  end

  def set_privilege_rate
    if current_user.update(params.require(:user).permit(:privilege_rate))
      redirect_to account_path(anchor: 'showpcards'), notice: '设置成功'
    else
      flash.now[:error] = model_errors(current_user).join('<br/>')
      render :edit_rate
    end
  end

  private
  def set_sharing_link_node
    @seller_sharing_link_node ||=
      SharingNode.find_or_create_by_resource_and_parent(current_user, @seller)
  end

end
