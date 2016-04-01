class ServiceStoresController < ApplicationController
  include SharingResource

  layout 'mobile'
  before_action :authenticate_user!, except: [:show]
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
    @advertisements = get_advertisements

    if @sharing_node && @sharing_node.user != current_user
      @promotion_activity = PromotionActivity.find_by(user_id: @seller.id, status: 1)
      @draw_record = ActivityDrawRecord.find_by(user_id: current_user.try(:id), activity_info_id: @promotion_activity.share_activity_info.id)
    end
  end

  def share
    @service_store = current_user.service_store
  end

  def verify_detail
    @verify_codes = VerifyCode.today(current_user) + VerifyCode.activity_today(current_user)
    @total = VerifyCode.total(current_user).size + VerifyCode.activity_total(current_user).size
    @today = VerifyCode.today(current_user).size + VerifyCode.activity_today(current_user).size
  end

  def verify
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      flash[:success] = result[:message]
    else
      flash[:error] = '验证失败'
    end
    redirect_to service_stores_path
  end

  private
  def get_advertisements
    Advertisement.where(user_type: 'Service', user_id: @seller.id).order('order_number')
  end

end
