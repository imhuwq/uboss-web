class AccountsController < ApplicationController

  layout :login_layout, only: [:set_password, :new_password, :merchant_confirm]
  before_action :authenticate_user!

  def show
    @orders = append_default_filter account_orders, page_size: 20
  end

  def orders
    @orders = append_default_filter account_orders, page_size: 20
    render partial: 'accounts/order', collection: @orders
  end

  def edit
  end

  def update
    if account_params[:login].present? and account_params[:code].present?
     MobileAuthCode.auth_code(account_params[:login], account_params[:code])
     current_user.update(login: account_params[:login])
     flash[:notice] = '绑定成功'
     redirect_to settings_account_path
     return
    elsif current_user.update(account_params)
      flash[:notice] = '修改成功'
      redirect_to settings_account_path
    else
      render :edit
    end
  end

  def new_password
    if flash[:new_password_enabled] != true
      redirect_to after_sign_in_path_for(current_user, need_new_passowrd: false)
    end
  end

  def set_password
    password_params = params.require(:user).permit(:password, :password_confirmation)
    if current_user.update(password_params.merge(need_reset_password: false))
      sign_in(current_user, bypass: true)
      flash[:notice] = '密码设定成功'
      redirect_to after_sign_in_path_for(current_user)
    else
      flash.now[:new_password_enabled] = true
      flash.now[:error] = current_user.errors.full_messages.join('<br/>')
      render :new_password
    end
  end

  def merchant_confirmed
    if current_user.is_seller?
      flash[:notice] = '您已经是UBoss商家'
      redirect_to after_sign_in_path_for(current_user)
    else
      current_user.become_uboss_seller
      redirect_to binding_agent_admin_account_path
    end
  end

  def edit_mobile_page
    if current_user.login.present?
      flash[:info] = "你已经有帐号了"
      redirect_to settings_account_path
    end
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password,:code)
    update_with_password_params = params.require(:user).permit(:password, :password_confirmation, :current_password)
    if  current_user.need_reset_password
      if MobileAuthCode.auth_code(current_user.login, user_params[:code])
        current_user.update(password: user_params[:password], password_confirmation: user_params[:password_confirmation],need_reset_password:false)
        sign_in current_user, :bypass => true
        redirect_to settings_account_path, notice: '修改密码成功'
      else
        flash.now[:error] = '验证码错误'
        render :update_password_page
        return
      end
    elsif current_user.update_with_password(update_with_password_params)
      sign_in current_user, :bypass => true
      redirect_to settings_account_path, notice: '修改密码成功'
    else
      flash.now[:error] = current_user.errors.full_messages.joins('<br/>')
      render :update_password_page
    end
  end

  def reset_password
    current_user.update(need_reset_password: true)
    redirect_to update_password_page_account_path
  end

  private
  def account_orders
    current_user.orders.includes(order_items: { product: :asset_img })
  end

  def account_params
    if current_user.login.present?
      params.require(:user).permit(:mobile, :nickname, :login)
    else
      params.require(:user).permit(:nickname)
    end
  end

end
