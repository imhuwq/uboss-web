class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def edit
  end

  def update
    if current_user.update(account_params)
      flash[:notice] = '修改成功'
      redirect_to edit_account_path
    else
      render :edit
    end
  end

  def settings # 个人信息展示
  end

  def update_password_page # 修改密码页面
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password)

    if current_user.update_with_password(user_params)
      sign_in current_user, :bypass => true
      redirect_to root_path, notice: '修改密码成功'
    else
      render :update_password_page
    end
  end

  def set_password
  end

  private
  def account_params
    params.require(:user).permit(:mobile, :nickname)
  end

end
