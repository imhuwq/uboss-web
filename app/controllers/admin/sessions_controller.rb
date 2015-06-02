class Admin::SessionsController < Admin::BaseController
  
  def new
  end
  
  def create
    user = User.find_by_account(params[:session][:account])
    if user && user.authenticate(params[:session][:password]) && user.status == "start"
      sign_in(user)
      redirect_back_or(user)
    else
      flash.now[:error] = '用户名或密码错误'
      render 'new'
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  def active_user
    @user= User.find_by_remember_token(params[:active_code])
    @user.status = "start"
    if @user.present? && @user.save 
      sign_in(@user)
      flash[:success] = "激活成功，现在开始添加你喜欢的歌曲吧~"
      redirect_to :controller=>:audios,:action=>:index
    else
      flash[:error] = "激活码已过期，请重新注册。"
      redirect_to :action=>'new'
    end
  end
  def try_to_reset_password
  end
  def send_reset_password_email
    if params[:session].present? && params[:session][:email].present?
      @user= User.find_by_email(params[:session][:email])
      message = "您申请的重置密码需求已经收到，请点击下列链接开始重置：#{request.protocol}#{request.host_with_port}/sessions/reset_password?active_code=#{@user.remember_token}"
      send_mail = UserMailer.sendmail(@user.email, "《音乐超文本》系统邮件", "重置密码", message)
      send_mail.deliver
      flash[:success] =  "请求发送成功,请查看您的注册邮箱并进一步重置密码。"
      redirect_to :action=>:new
    else
      flash[:error] = "您的输入有误。"
      render :action=>:try_to_reset_password
    end
  end
  def reset_password
    user= User.find_by_remember_token(params[:active_code])
    if user.present? && user.remember_token_expires_at > Time.now
      @user= user
    else
      flash[:notice] = "本链接已经过期，请重新申请密码找回。"
    end

  end
  def update
    puts user_params
    @user= User.find_by_id(params[:id])
    if @user.update_attributes(user_params)
      sign_in(@user)
      flash[:success] = "密码修改成功~"
      redirect_to :controller=>:audios,:action=>:index
    else
      flash[:error] = "密码修改失败，请重新尝试或联系管理员。"
      redirect_to :action=>'new'
    end
  end
  def user_params
    params.require(:user).permit(:name,:mail,:password,:password_confirmation)
  end
  
end