class CallingServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_seller
  before_action :find_unuse_table_numbers, only: [:table_numbers, :set_table_number]

  def index
    if cookies[:table_nu].blank?
      redirect_to action: :table_numbers
    else
      @calling_services = @seller.calling_services
    end
  end

  def table_numbers
    @select_arr = @table_numbers.pluck(:number, :id)
  end

  def set_table_number
    table_number = @table_numbers.find_by(id: params[:table_number][:number])

    if table_number
      cookies[:table_nu] = table_number.number
      table_number.update(status: 1)
      redirect_to action: :index
    else
      flash[:error] = "请选择正确的桌号"
      redirect_to action: :table_numbers
    end
  end

  private
  def find_unuse_table_numbers
    @table_numbers = TableNumber.where(user: @seller, status: 0)
  end

  def find_seller
    @seller = User.find(params[:seller_id])
  end
end
