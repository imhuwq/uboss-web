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

  def set_password
  end

  private
  def account_params
    params.require(:user).permit(:mobile, :nickname)
  end

end
