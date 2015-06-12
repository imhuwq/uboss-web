class UserAddressesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_user_address, only: [:show, :edit, :update, :destroy]

  def index
    @user_addresses = current_user.user_addresses
  end

  def show
  end

  def new
    @user_address = current_user.user_address.new(mobile: current_user.mobile)
  end

  def create
    @user_address = current_user.user_address.new(address_params)
    if @user_address.save
      redirect_to account_user_addresses_path 
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user_address.update(address_params)
      redirect_to account_user_addresses_path
    else
      render :edit
    end
  end

  def destroy
    if @user_address.destroy
      flash[:notice] = '删除收货地址成功'
      redirect_to account_user_addresses_path
    else
      flash[:error] = '删除收货地址失败'
      redirect_to account_user_addresses_path
    end
  end

  private
  def address_params
    params.require(:user_address).premit(:username, :mobile, :province, :city, :country, :street)
  end

  def find_user_address
    @user_addresses ||= current_user.user_addresses.find(params[:id])
  end
  
end
