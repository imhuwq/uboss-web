# 提现
class WithdrawRecordsController < ApplicationController
    
  def show
	render layout: 'mobile'
  end

  def new
    @withdraw_record = WithdrawRecord.new(amount: nil)
    render layout: 'mobile'
  end

  def create
    amount = params.require(:withdraw_record).permit(:amount)
    @withdraw_record = WithdrawRecord.new(amount)
    @withdraw_record.user = current_user
    if @withdraw_record.save
      redirect_to action: :success, id: @withdraw_record.id
    else
      flash[:error] = model_errors(@withdraw_record).join('<br/>')
      render :new
    end
  end

  def success
    @withdraw_record = WithdrawRecord.find(params[:id])
    render layout: 'mobile'
  end
end
