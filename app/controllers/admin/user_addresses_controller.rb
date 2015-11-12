class Admin::UserAddressesController < AdminController

  load_and_authorize_resource

  def index
    @user_addresses = current_user.user_addresses.order('created_at DESC').page(param_page)
  end

  def new
  end

  def edit
    @user_address = current_user.user_addresses.find(params[:id])
  end

  def update
    @user_address.update(user_address_params)
    default_get_address = params[:user_address][:usage][:default_get_address]
    default_post_address = params[:user_address][:usage][:default_post_address]
    @user_address.usage['default_get_address'] = "#{default_get_address}" if ['true', 'false'].include?(default_get_address)
    @user_address.usage['default_post_address'] = "#{default_post_address}" if ['true', 'false'].include?(default_post_address)
    if @user_address.save
      flash[:success] = "保存成功"
      redirect_to action: :index
    else
      @user_address.valid?
      flash[:error] = "#{@user_address.errors.full_messages.join('<br/>')}"
      redirect_to action: :edit, id: params[:id]
    end
  end

  def destroy
    current_user.user_addresses.find(params[:id]).destroy
    redirect_to action: :index
  end

  def create
    user_address = UserAddress.new(user_address_params)
    default_get_address = params[:user_address][:usage][:default_get_address]
    default_post_address = params[:user_address][:usage][:default_post_address]
    user_address.usage['default_get_address'] = "#{default_get_address}" if ['true', 'false'].include?(default_get_address)
    user_address.usage['default_post_address'] = "#{default_post_address}" if ['true', 'false'].include?(default_post_address)
    user_address.user = current_user
    if user_address.save
      flash[:success] = "保存成功"
      redirect_to action: :index
    else
      user_address.valid?
      flash[:error] = "#{user_address.errors.full_messages.join('<br/>')}"
      render 'new'
    end
  end

  private
  def user_address_params
    params.require(:user_address).permit(
    :username, :mobile, :province, :city, :area, :building, :post_code, :note
    )
  end
end
