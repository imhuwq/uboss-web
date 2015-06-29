class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = User.admin.recent.page(param_page)
  end

  def show
  end

  def new
    @user = User.new()
  end

  def create
    @user = User.new(user_params.merge(admin: true))
    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permit_keys = [:email, :mobile, :nickname, :user_role_id]
    if params[:action] == "create"
      permit_keys += [:login, :password, :password_confirmation]
    end
    params.require(:user).permit(permit_keys)
  end

end
