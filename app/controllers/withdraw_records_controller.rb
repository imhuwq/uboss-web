class WithdrawRecordsController < ApplicationController

  def show
  end

  def new
    @withdraw_record = current_user.withdraw_records.new(amount: nil)
  end

  def create
    amount = params.require(:withdraw_record).permit(:amount, :bank_card_id)
    @withdraw_record = current_user.withdraw_records.new(amount)
    if @withdraw_record.save
      redirect_to action: :success, id: @withdraw_record.id
    else
      flash.now[:error] = model_errors(@withdraw_record).join('<br/>')
      render :new
    end
  end

  def success
    @withdraw_record = WithdrawRecord.find(params[:id])
  end
end
