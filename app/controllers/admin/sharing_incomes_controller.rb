class Admin::SharingIncomesController < AdminController

  def index
    @sharing_incomes = current_user.sharing_outcomes.recent.page(param_page).
      includes(:user, order_item: :product)
  end

  def show
    @sharing_income = current_user.sharing_outcomes.find(params[:id])
  end

end
