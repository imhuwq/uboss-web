class PrivilegeCardsController < ApplicationController
  def index
  end

  def show
  end

  def update
    amount_params = params.require(:privilege_card).permit(:privilege_amount)
    @privilege_card = current_user.privilege_cards.find(params[:id])
    if @privilege_card.update(amount_params)
      render json: { actived: @privilege_card.actived }
    else
      render json: @privilege_card.errors.full_messages.join('，'), status: :failure
    end
  end
end
