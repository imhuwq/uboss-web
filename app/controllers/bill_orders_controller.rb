class BillOrdersController < ApplicationController

  before_action :authenticate_user!, only: [:index]
  before_action :authenticate_weixin_user_token!, only: [:new, :show]

  def index
    @bill_orders = append_default_filter current_user.bill_orders
  end

  def show
    @bill_order = if current_user.present?
                    current_user.bill_orders.find(params[:id])
                  else
                    BillOrder.where(weixin_openid: get_weixin_openid_form_session).find(params[:id])
                  end
  end

  def new
    @bill_order = BillOrder.new
    @service_store = ServiceStore.find(params[:service_store_id])
  end

end
