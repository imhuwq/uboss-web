class Admin::WechatAccountsController < AdminController

  load_and_authorize_resource

  def index
    @wechat_accounts = append_default_filter @wechat_accounts
  end

  def show
  end

  def new
  end

  def create
    if @wechat_account.save
      redirect_to admin_wechat_account_path(@wechat_account)
    else
      flash.now[:error] = model_errors(@wechat_account).join('<br/>')
      render :new
    end
  end

  def edit
    @wechat_account.app_secret = ""
  end

  def update
    if @wechat_account.update(resource_params)
      redirect_to admin_wechat_account_path(@wechat_account)
    else
      @wechat_account.app_secret = nil
      flash.now[:error] = model_errors(@wechat_account).join('<br/>')
      render :edit
    end
  end

  def destroy
    if @wechat_account.destroy
      redirect_to admin_wechat_accounts_path
    else
      flash.now[:error] = model_errors(@wechat_account).join('<br/>')
      render :show
    end
  end

  private

  def resource_params
    params.require(:wechat_account).
      permit(:name, :encoding_aes_key, :app_id, :app_secret, :wechat_identify)
  end

end
