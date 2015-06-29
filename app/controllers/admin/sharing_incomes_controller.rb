class Admin::SharingIncomesController < AdminController
  load_and_authorize_resource

  def index
    @sharing_incomes = @sharing_incomes.recent.page(param_page).
      includes(:user, order_item: :product)
  end

  def show
  end

end
