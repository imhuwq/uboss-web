# 提现
class WithdrawRecordsController < ApplicationController
	def show
  end

  def new
    @income = current_user.user_info.income
    @withdraw_record = WithdrawRecord.new(amount: nil)
  end

  def create
    amount = params.require(:withdraw_record).permit(:amount)
    @withdraw_record = WithdrawRecord.new(amount)
    @withdraw_record.user = current_user
    if @withdraw_record.save
      redirect_to action: :success, id: @withdraw_record.id
    else
      puts @withdraw_record.errors.full_messages.join('<br/>')
      flash[:error] = @withdraw_record.errors.full_messages.join('<br/>')
      redirect_to 'new'
    end
  end

  def success
    @withdraw_record = WithdrawRecord.find(params[:id])
  end
end
