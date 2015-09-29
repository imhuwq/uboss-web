class Admin::WithdrawRecordsController < AdminController

  load_and_authorize_resource

  def index
    @withdraw_records = @withdraw_records.order('id DESC').page(param_page)
  end

  def show
  end

  def new
    if current_user.weixin_openid.blank? && current_user.bank_cards.count < 1
      flash[:notice] = "请添加银行卡以用于提现"
      redirect_to new_admin_bank_card_path
    else
      @withdraw_record.user = current_user
    end
  end

  def create
    if @withdraw_record.save
      redirect_to [:admin, @withdraw_record]
    else
      render :new
    end
  end

  def processed
    @withdraw_record.transfer_remote_ip = request.ip
    change_record_state(:process!)
  end

  def close
    change_record_state(:close!)
  end

  def generate_excel
    excel = Axlsx::Package.new
    excel.workbook.add_worksheet(:name => "Basic Worksheet") do |sheet|
      sheet.add_row ["编号", "申请人", "收款人", "收款银行", "收款账号", "申请时间", "金额", "状态"]
      @withdraw_records.find_each do |record|
        sheet.add_row [record.number, record.user_identify, record.card_username, record.target_title, record.target_content.to_s, record.created_at, record.amount, record.state_i18n],
          :types => [nil, nil, nil, nil, :string, nil, nil, nil]
      end
    end
    send_data excel.to_stream.read, :filename => "UBOSS提现记录总表#{Date.today}.xlsx", :type => 'application/xlsx'
  end

  private
  def create_params
    params.require(:withdraw_record).permit(:amount, :bank_card_id)
  end

  def change_record_state(action)
    if @withdraw_record.send(action)
      flash[:notice] = "编号：#{@withdraw_record.number} 处理成功。"
      redirect_to :back
    else
      flash[:error] = "编号：#{@withdraw_record.number} 处理失败。<br/>错误信息：#{@withdraw_record.errors.full_messages.join('<br/>')}"
      redirect_to :back
    end
  end

end
