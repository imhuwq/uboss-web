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

  def set_menu
    client = WechatAccount.get_wexin_client(wechat_account: @wechat_account)
    result = client.create_menu(
      button: [
        {
          name: '专属二维码',
          type: 'click',
          key: 'personal_invite_qrcode'
        }, {
          name: 'U主页',
          type: 'view',
          url: Rails.application.secrets['host_url']
        }, {
          name: '我的收益',
          type: 'click',
          key: 'invitor_income_link'
        }
      ]
    )
    if result.is_ok?
      flash[:notice] = '设置成功'
    else
      flash[:error] = client.en_msg || client.cn_msg
    end
    redirect_to admin_wechat_account_path(@wechat_account)
  end

  private

  def resource_params
    params.require(:wechat_account).
      permit(:name, :encoding_aes_key, :app_id, :app_secret, :wechat_identify)
  end

end
