class Admin::SubAccountsController < AdminController

  load_and_authorize_resource

  def index
    @sub_accounts = append_default_filter @sub_accounts
  end

  def create
    if @sub_account.save
      flash[:notice] = '绑定成功'
      redirect_to admin_sub_accounts_path
    else
      flash.now[:error] = model_errors(@sub_account).join('<br/>')
      render :new
    end
  end

  def update
    if @sub_account.save
      redirect_to :back
    else
      flash[:error] = model_errors(@sub_account).join('<br/>')
      redirect_to sub_accounts_path
    end
  end

  def new
  end

  def block
    change_sub_account_state_to('block')
  end

  def active
    change_sub_account_state_to('active')
  end

  private

  def change_sub_account_state_to(state)
    if @sub_account.update(state: state)
      flash[:notice] = '操作成功'
    else
      flash[:error] = "操作失败：#{model_errors(@sub_account).join("<br/>")}"
    end
    redirect_to :back
  end

  def resource_params
    params.require(:sub_account).permit(:account_id, :state)
  end
end
