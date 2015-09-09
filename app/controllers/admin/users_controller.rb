class Admin::UsersController < AdminController
  load_and_authorize_resource

  def index
    @users = User.admin.recent.page(param_page)
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
    if @user.update(resource_params)
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  private

  def resource_params
    permit_keys = [:password, :password_confirmation, :email, :mobile, :nickname, :user_role_id]
    if params[:action] == "create"
      permit_keys += [:login]
    end
    params.require(:user).permit(permit_keys)
  end

end
