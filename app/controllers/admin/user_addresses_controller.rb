class Admin::UserAddressesController < AdminController

  load_and_authorize_resource

  def index
    @user_addresses = current_user.seller_addresses.order('created_at DESC').page(param_page)
  end

  def new
  end

  def edit
    @user_address = current_user.seller_addresses.find(params[:id])
  end

  def update
    @user_address = current_user.seller_addresses.find(params[:id])

    if @user_address.update(user_address_params)
      flash[:success] = "保存成功"
      redirect_to action: :index
    else
      @user_address.valid?
      flash[:error] = "#{@user_address.errors.full_messages.join('<br/>')}"
      redirect_to action: :edit, id: params[:id]
    end
  end

  def destroy
    user_address = current_user.seller_addresses.find(params[:id])
    if user_address.default_get_address == 'true' || user_address.default_post_address == 'true'
      flash[:error] = "删除失败,不能删除默认地址，请先设置其他默认地址。"

    elsif user_address.destroy
      flash[:success] = "删除成功"
    else
      flash[:error] = "删除失败"
    end
    redirect_to action: :index
  end

  def create
    user_address = UserAddress.new(user_address_params)
    user_address.user = current_user
    user_address.seller_address = true
    if user_address.save
      flash[:success] = "保存成功"
      redirect_to action: :index
    else
      user_address.valid?
      flash.now[:error] = "#{user_address.errors.full_messages.join('<br/>')}"
      render 'new'
    end
  end

  def change_default_address
    user_address = UserAddress.where('seller_address = ?', true).find(params[:id])
    if params[:title] == '发货地址'
      user_address.default_post_address = 'true'

    elsif params[:title] == '退货地址'
      user_address.default_get_address = 'true'
    end

    if user_address.save
      flash.now[:success] = "#{params[:title]}已经修改为：#{user_address.to_s}"
    else
      flash.now[:error] = "#{user_address.errors.full_messages.join('<br/>')}"
    end
    data = {default_post_address: current_user.default_post_address.to_s, default_get_address: current_user.default_get_address.to_s}
    render json: data
  end

  private
  def user_address_params
    params.require(:user_address).permit(
    :username, :mobile, :province, :city, :area, :building, :post_code, :note,
    :default_get_address, :default_post_address
    )
  end
end
