class CallingServicesController < ApplicationController
  before_action :find_seller
  before_action :find_unuse_table_numbers, only: [:table_numbers, :set_table_number]
  before_action :find_using_table_number,  only: [:index, :notifies]

  def index
    @calling_services = @seller.calling_services
  end

  def table_numbers
    @select_arr = @table_numbers.pluck(:number, :id)
  end

  def set_table_number
    table_number = @table_numbers.find_by(number: params[:table_number][:number])

    if table_number
      TableNumber.clear_seller_table_number(@seller, cookies[:table_nu])
      cookies[:table_nu] = table_number.number
      table_number.update(status: 1)
      redirect_to action: :index
    else
      flash[:error] = "请选择正确的桌号"
      redirect_to action: :table_numbers
    end
  end

  def notifies
    @calling_notifies = CallingNotify.where(user: @seller, table_number: @table_number)
  end

  private
  def find_seller
    @seller = User.find(params[:seller_id])
  end

  def find_unuse_table_numbers
    @table_numbers = TableNumber.where(user: @seller, status: 0)
  end

  def find_using_table_number
    unless @table_number = TableNumber.find_by(user: @seller, number: cookies[:table_nu])
      redirect_to action: :table_numbers
    end
  end
end
