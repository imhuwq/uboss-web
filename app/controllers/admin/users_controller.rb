class Admin::UsersController < AdminController

  before_action :authorize_user_managing_permissions, only: [:show, :new, :create, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]

  def index
    authorize! :handle, User
    @users = append_default_filter User.accessible_by(current_ability)
  end

  def show
  end

  def new
    @user = User.new()
  end

  def create
    @user = User.new(resource_params)
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

  def authorize_user_managing_permissions
    authorize! :manage, User
  end

  def set_user
    @user = User.find(params[:id])
  end

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
    @resource_params = params.require(:user).permit(permit_keys)
    allow_role_ids = UserRole.roles_can_manage_by_user(current_user).pluck(:id)
    existing_role_ids = @user.user_role_ids
    over_premission_role_ids = existing_role_ids - allow_role_ids
    @resource_params[:user_role_ids].each do |role_id|
      @resource_params[:user_role_ids].delete(role_id) unless allow_role_ids.include?(role_id.to_i)
    end
    @resource_params[:user_role_ids] |= over_premission_role_ids
    @resource_params
  end

end
