class Api::V1::BankCardsController < ApiBaseController

  def create
    authorize! :create, BankCard
    @bank_card = current_user.bank_cards.build(bank_card_params)
    if @bank_card.save
      head(200)
    else
      render_model_errors @bank_card
    end
  end

  def destroy
    @bank_card = BankCard.find_by(id: params[:id])
    authorize! :destroy, @bank_card
    if @bank_card.destroy
      head(200)
    else
      render_error :wrong_params
    end
  end

  private

  def bank_card_params
    params.permit(:username, :bankname, :number)
  end

end
