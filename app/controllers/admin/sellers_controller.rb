class Admin::SellersController < AdminController

  before_action :set_seller, only: [:show, :update, :edit]

  def index
    authorize! :read, :sellers
    @sellers = User.role('seller')
    if cannot?(:handle, :sellers)
      @sellers = @sellers.where(agent_id: current_user.id)
    end
    @sellers = @sellers.page(params[:page] || 1).per(15)
  end

  def show
    authorize! :read, @seller
    @agent = @seller.agent

    @personal_authentication = PersonalAuthentication.find_by(user_id: @seller.id) || PersonalAuthentication.new
    @enterprise_authentication = EnterpriseAuthentication.find_by(user_id: @seller.id) || EnterpriseAuthentication.new

    @sold_daily_reports = @seller.daily_reports.user_order.where(user: @seller)
    @sold_month_reports = @sold_daily_reports.aggregate_by_month.page(1)
    @sold_daily_reports = @sold_daily_reports.order('day DESC').page(1)

    if @agent.present?
      @agent_daily_reports = DailyReport.seller_divide.where(user: @agent, seller_id: @seller.id)
      @agent_month_reports = @agent_daily_reports.aggregate_by_month.page(1)
      @agent_daily_reports = @agent_daily_reports.order('day DESC').page(1)
    end
  end

  def edit
    authorize! :update, @seller
  end

  def update
    authorize! :update, @seller
    if @seller.ordinary_store.update(seller_params)
      flash[:notice] = '更新成功'
      redirect_to action: :edit
    else
      flash.now[:error] = model_errors(@seller).join('<br/>')
      render :edit
    end
  end

  def update_service_rate
    authorize! :update_service_rate, :uboss_seller
    user_params = params.require('user_info').permit(:platform_service_rate, :agent_service_rate)

    @ordinary_store = OrdinaryStore.find_by!(user_id: params[:id])

    if @ordinary_store.update(user_params)
      render json: {
        id: @ordinary_store.user_id,
        platform_service_rate: @ordinary_store.platform_service_rate,
        agent_service_rate: @ordinary_store.agent_service_rate
      }
    else
      render json: { message: @ordinary_store.errors.full_messages.join('，') }, status: 422
    end
  end

  def my_suppliers
    @my_suppliers = current_user.suppliers.includes(supplier_store: :supplier_store_info).page(params[:page])
    @statistics = {}
    @statistics[:count] = @my_suppliers.total_count
  end

  private

  def set_seller
    @seller = User.find(params[:id])
  end

  def seller_params
    params.require(:user).permit(
      :store_banner_one,          :store_banner_two,          :store_banner_thr,
      :recommend_resource_one_id, :recommend_resource_two_id, :recommend_resource_thr_id,
      :store_name, :store_short_description, :store_cover,
    )
  end
end
