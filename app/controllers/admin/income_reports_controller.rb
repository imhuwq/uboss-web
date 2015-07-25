class Admin::IncomeReportsController < AdminController

  load_and_authorize_resource :seller, class: 'User'
  load_and_authorize_resource :daily_report, parent: false

  def index
    @daily_reports = @daily_reports.user_order.
      includes(user: :user_info).order('day DESC').page(params[:dpage] || param_page)

    if @seller
      @daily_reports = @daily_reports.recent.where(user: @seller)
      @agent_daily_reports = DailyReport.seller_divide.where(
        user: current_user,
        seller_id: @seller.id
      ).order('day DESC').page(params[:adpage] || param_page)
      render :details
    else
      @total_divide_income = current_user.divide_incomes.sum(:amount)
      @today_divide_income = current_user.divide_incomes.today.sum(:amount)
    end
  end

  def show
  end

end
