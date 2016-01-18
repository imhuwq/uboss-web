class ServiceStoresController < ApplicationController
  include SharingResource

  layout 'mobile'

  before_action :login_app, only: [:show]

  def index
    @service_store = current_user.service_store
  end

  def show
    @service_store = ServiceStore.find(params[:id])
    @seller = @service_store.user
    get_sharing_node
    set_sharing_link_node
    @voucher_products = append_default_filter @service_store.service_products.vouchers.published, order_column: :updated_at
    @group_products = append_default_filter @service_store.service_products.groups.published, order_column: :updated_at
  end

  def share
    @service_store = current_user.service_store
  end

  def verify_detail
    @verify_codes = VerifyCode.today(current_user)
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def verify
    service_product_ids = ServiceProduct.where(user_id: current_user.id).ids
    order_item_ids = OrderItem.where(product_id: service_product_ids).ids
    @verify_code = VerifyCode.where(code: params[:code], order_item_id: order_item_ids).first

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to service_stores_path
  end
end
