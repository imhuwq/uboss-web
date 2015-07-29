class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = append_default_filter current_user.orders, page_size: 10
  end

  def orders
    @orders = append_default_filter current_user.orders, page_size: 10
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

  def settings # 个人信息展示
  end

  def update_password_page # 修改密码页面
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
        render :update_password_page
        return
      end
    elsif current_user.update_with_password(update_with_password_params)
      sign_in current_user, :bypass => true
      redirect_to settings_account_path, notice: '修改密码成功'
    else
      render :update_password_page
    end
  end

  def set_password
  end

  def reset_password
    current_user.update(need_reset_password: true)
    redirect_to update_password_page_account_path
  end

  private
  def account_params
    if current_user.login.present?
      params.require(:user).permit(:mobile, :nickname, :login)
    else
      params.require(:user).permit(:nickname)
    end
  end

end
