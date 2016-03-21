class Admin::DishesProductsController < AdminController
  def index
    @statistics = {}
    @dishes = DishesProduct.all.page(params[:page] || 1)
  end

  def edit
    @dishes_product = DishesProduct.find(params[:id])
  end

  def update
    @dishes_product = DishesProduct.find(params[:id])
    if @dishes_product.update(dishes_product_params)
      flash[:success] = '更新菜品成功'
      redirect_to admin_dishes_products_path
    else
      flash.now[:error] = "#{@dishes_product.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def new
    @dishes_product = DishesProduct.new()
  end

  def change_status
    @product = DishesProduct.find(params[:id])
    if params[:status] == 'published'
      @product.status = 'published'
      @notice = '上架成功'
    elsif params[:status] == 'unpublish'
      @product.status = 'unpublish'
      @notice = '取消上架成功'
    elsif params[:status] == 'closed'
      @product.status = 'closed'
      @notice = '删除成功'
    end

    if !@product.save
      @error = model_errors(@product).join('<br/>')
    end
    if request.xhr?
      flash.now[:success] = @notice
      flash.now[:error] = @error
      product_collection = @product.closed? ? [] : [@product]
      render(partial: 'products', locals: { dishes: product_collection })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show, id: @product.id
    end
  end

  def create
    @dishes_product = DishesProduct.new(dishes_product_params)
    @dishes_product.user_id = current_user.id
    @dishes_product.service_store = current_user.service_store
    if @dishes_product.save
      flash[:success] = '菜品创建成功'
      redirect_to admin_dishes_products_path
    else
      flash.now[:error] = "#{@dishes_product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  private
  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def dishes_product_params
    dishes = params.require(:dishes_product).permit(
      :name, :present_price, :rebate_amount, :avatar,
    )
    if params[:product].present?
      dishes = dishes.merge(params.require(:product).permit(
      product_inventories_attributes: [
        :id, :price, :share_amount_total,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
      ))
    end

    if params[:ordinary_product].present?
      dishes = dishes.merge(params.require(:ordinary_product).permit(:categories))
    end
    dishes
  end
end
