class Admin::SellersController < AdminController

  before_action :set_seller, only: [:show, :update, :edit]

  def index
    authorize! :read, :sellers
    if current_user.is_super_admin?
      @sellers = User.joins(:user_roles).where(user_roles: { name: 'seller' }).page(params[:page] || 1).per(15)
    else
      @sellers = User.joins(:user_roles).where(user_roles: { name: 'seller' }, agent_id: current_user.id).page(params[:page] || 1).per(15)
    end
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
    if @seller.update(seller_params)
      flash[:notice] = '更新成功'
      redirect_to action: :edit
    else
      flash.now[:error] = model_errors(@seller).join('<br/>')
      render :edit
    end
  end

  def update_service_rate
    user_info = UserInfo.find_by(user_id: params['seller']['id'])
    to_service_rate = params['seller']['service_rate']
    if to_service_rate.present? && user_info.present?
      from_service_rate = user_info.service_rate
      if to_service_rate.to_f >= 5 && to_service_rate.to_f <= 10
        user_info.update(service_rate: to_service_rate)
        user_info.service_rate_histroy = {}
        user_info.service_rate_histroy[Time.now.to_datetime] = { from_service_rate: from_service_rate, to_service_rate: to_service_rate }
        if user_info.save
          flash[:success] = '保存成功'
        else
          flash[:error] = "保存失败：#{user_info.errors.full_messages.join('<br/>')}"
        end
      else
        flash[:error] = '可选范围介于5%~10%'
      end
    else
      flash[:error] = "提交的参数有误：#{params}"
    end
    redirect_to action: :show, id: user_info.user_id
  end

  private

  def set_seller
    @seller = User.find(params[:id])
  end

  def seller_params
    params.require(:user).permit(
      :store_banner_one,          :store_banner_two,          :store_banner_thr,
      :recommend_resource_one_id, :recommend_resource_two_id, :recommend_resource_thr_id,
      :store_name
    )
  end
end
