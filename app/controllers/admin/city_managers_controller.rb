class Admin::CityManagersController < AdminController
  load_and_authorize_resource
  before_action :set_city_manager, only: [:revenues, :added]
  def index
    conditions = case params[:category]
    when 'today' then ['DATE(certifications.verified_at) = ?', Date.today]
    when 'month' then { certifications: { verified_at: Time.now.beginning_of_month..Time.now.end_of_month } }
    end

    @city_managers = CityManager.joins(:enterprise_authentications).
    where(certifications: { status: 2}).where(conditions).
    distinct("enterprise_authentications.city_code").
    preload(:user).page(params[:page])
  end

  def cities
    @q = CityManager.search(search_params)
    @city_managers = append_default_filter @q.result.preload(:user), order_column: :updated_at
  end

  def revenues
    params[:segment] ||= 'today'
    scope = Order.have_paid.where(seller_id: certifications.joins(:user).pluck("users.id"))

    # 今日营业额
    @today_turnovers  = scope.today.sum(:paid_amount)

    # 今日销量
    @today_sales      = scope.today.joins(:order_items).sum("order_items.amount")

    # 总营业额
    @total_turnovers  = scope.sum(:paid_amount)

    # 总销量
    @total_sales      = scope.joins(:order_items).sum("order_items.amount")

    @certifications   = certifications.page(params[:page])
  end

  def added
    params[:segment] ||= 'today'
    scope = %w(today week month).include?(params[:segment]) ? params[:segment] : 'today'
    @total = certifications
    @certifications = @total.send(scope).page(params[:page])
  end

  def bind
    @city_manager = CityManager.find params[:id]
    @city_manager.user_id_will_change!
    if @city_manager.user_id.present?
      flash[:error] = "该地区已绑定城市运营商, 请解绑后重试"
    else
      user = User.find_or_create_guest_with_session(params[:mobile], {})
      if user.new_record?
        flash[:error] = "绑定失败: #{user.errors.full_messages.join(',')}"
      else
        if user.previous_changes.present?
          Ubonus::Invite.delay.active_by_user_id(user.id)
        end
        if @city_manager.update(user_id: user.id, rate: params[:rate])
          flash[:notice] = "绑定成功"
        else
          flash[:error] = "绑定失败: #{@city_manager.errors.full_messages.join(',')}"
        end
      end
    end
    respond_to do |format|
      format.js { render template: 'admin/city_managers/binding' }
    end
  end

  def unbind
    @city_manager = CityManager.find params[:id]
    @city_manager.user_id_will_change!
    if @city_manager.update(user_id: nil)
      flash[:notice] = "解绑成功"
    else
      flash[:error] = '解绑失败'
    end
    respond_to do |format|
      format.js { render template: 'admin/city_managers/binding' }
    end
  end

  private
  def search_params
    params[:category_eq] = params[:category]
    params.permit(:category_eq)
  end

  def set_city_manager
    @city_manager = CityManager.find_by_user_id(current_user.id) || CityManager.new
  end

  def certifications
    EnterpriseAuthentication.pass.by_city(@city_manager.city)
  end
end
