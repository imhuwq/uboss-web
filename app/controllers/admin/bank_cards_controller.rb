class Admin::BankCardsController < AdminController
  load_and_authorize_resource

  def index
    @bank_cards = @bank_cards.order("id DESC")
  end

  def new
  end

  def edit
  end

  def create
    if @bank_card.save
      redirect_to [:admin, :bank_cards], notice: '创建成功'
    else
      render :new
    end
  end

  def update
    if @bank_card.update(update_params)
      redirect_to [:admin, :bank_cards], notice: '更新成功'
      redirect_to [:admin, :bank_cards]
    else
      render :edit
    end
  end

  def destroy
    if @bank_card.destroy
      redirect_to [:admin, :bank_cards], notice: '删除成功'
    else
      redirect_to [:admin, :bank_cards], error: @bank_card.errors.fullmessages.join(";")
    end
  end

  private
  def create_params
    params.require(:bank_card).permit(:username, :bankname, :number)
  end

  def update_params
    create_params
  end
end
