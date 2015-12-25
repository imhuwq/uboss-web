class Admin::CityManagersController < AdminController
  before_action :set_city_manager, only: [:revenues, :added]
  def index
    @q = CityManager.search(search_params)
    @city_managers = @q.result.preload(:user).page(params[:page])
  end

  def revenues
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
    @certifications = certifications.page(params[:page])
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
