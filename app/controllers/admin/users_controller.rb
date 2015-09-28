class Admin::UsersController < AdminController
  load_and_authorize_resource

  def index
    @users = append_default_filter @users.admin
  end

  def show
  end

  def new
    @user = User.new()
  end

  def create
    @user.admin = true
    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    authorize! :manage, @user
    if @user.update(resource_params)
      flash[:notice] = '更新成功'
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  private

  def resource_params
    permit_keys = [:password, :password_confirmation, :email, :mobile, :nickname, user_role_ids: []]
    if params[:action] == "create"
      permit_keys += [:login]
    end
    if not current_user.is_role?(:super_admin)
      permit_keys.delete(:user_role_ids)
    end
    if params[:action] == "update" && params[:user][:password].blank?
      permit_keys.delete(:password)
      permit_keys.delete(:password_confirmation)
    end
    params.require(:user).permit(permit_keys)
  end

end
