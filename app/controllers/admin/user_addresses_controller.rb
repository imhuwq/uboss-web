class Admin::UserAddressesController < AdminController
  def index
    @user_addresses = current_user.user_addresses.page(param_page)
  end
  def new
    @user_addresses = UserAddress.new
  end
  def edit
    @user_address = current_user.user_addresses.find(params[:id])
  end
  def destroy
    current_user.user_addresses.find(params[:id]).destroy
    redirect_to action: :index
  end
end
