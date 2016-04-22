class Api::V1::Admin::BankCardsController < ApiBaseController

  def index
    authorize! :read, BankCard
    @bank_cards = current_user.bank_cards
    render json: { data: @bank_cards }
  end

  def create
    authorize! :create, BankCard
    @bank_card = current_user.bank_cards.build(bank_card_params)
    if @bank_card.save
      render json: { data: { id: @bank_card.id } }
    else
      render_model_errors @bank_card
    end
  end

  def destroy
    @bank_card = BankCard.find_by(id: params[:id])
    authorize! :destroy, @bank_card
    if @bank_card.destroy
      render json: { data: {} }
    else
      render_error :wrong_params
    end
  end

  private

  def bank_card_params
    params.permit(:username, :bankname, :remark, :number)
  end

end
