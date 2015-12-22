class Admin::CityManagersController < AdminController
  def index
    @q = CityManager.search(search_params)
    @city_managers = @q.result.preload(:user).page(params[:page])
  end

  private
  def search_params
    params[:category_eq] = params[:category]
    params.permit(:category_eq)
  end
end
