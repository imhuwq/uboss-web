class Admin::UserAddressesController < AdminController
  def index
    @user_addresses = current_user.user_addresses.page(param_page)
  end
  def new
    @user_address = UserAddress.new
  end
  def edit
    @user_address = current_user.user_addresses.find(params[:id])
  end
  def destroy
    current_user.user_addresses.find(params[:id]).destroy
    redirect_to action: :index
  end
  def create
    user_address = UserAddress.new(user_address_params)
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
    :username, :mobile, :province, :city, :area, :street, :post_code, :note,
    :usage
    )
  end
end
