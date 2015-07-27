class Admin::WithdrawRecordsController < AdminController

  before_action :find_record, only: [:show, :processed, :finish, :close]

  def index
    @withdraw_records = WithdrawRecord.order('state ASC, id DESC').page(param_page)
  end

  def show
  end

  def processed
    @withdraw_record.transfer_remote_ip = request.ip
    change_record_state(:process!)
  end

  #def finish
    #change_record_state(:finish!)
  #end

  def close
    change_record_state(:close!)
  end

  private
  def find_record
    @withdraw_record = WithdrawRecord.find(params[:id])
  end

  def change_record_state(action)
    if @withdraw_record.send(action)
      flash.now[:notice] = "编号：#{@withdraw_record.number} 处理成功。"
      redirect_to :back
    else
      flash.now[:error] = "编号：#{@withdraw_record.number} 处理失败。"
      redirect_to :back
    end
  end

end
