class Admin::DishesProductsController < AdminController
  load_and_authorize_resource
  def index
    @statistics = {}
    @dishes = @dishes_products.available.order('created_at DESC').page(params[:page])
  end

  def edit
  end

  def update
    if @dishes_product.update(dishes_product_params)
      flash[:success] = '更新菜品成功'
      redirect_to admin_dishes_products_path
    else
      flash.now[:error] = "#{@dishes_product.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def new
  end

  def change_status
    if params[:status] == 'published'
      @dishes_product.status = 'published'
      @notice = '上架成功'
    elsif params[:status] == 'unpublish'
      @dishes_product.status = 'unpublish'
      @notice = '取消上架成功'
    elsif params[:status] == 'closed'
      @dishes_product.status = 'closed'
      @notice = '删除成功'
    end

    if !@dishes_product.save
      @error = model_errors(@dishes_product).join('<br/>')
    end
    if request.xhr?
      flash.now[:success] = @notice if @error.blank?
      flash.now[:error] = @error
      product_collection = @dishes_product.closed? ? [] : [@dishes_product]
      render(partial: 'products', locals: { dishes: product_collection })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show, id: @dishes_product.id
    end
  end

  def create
    @dishes_product.user_id = current_user.id
    @dishes_product.service_store = current_user.service_store
    @dishes_product.status = 'published'
    if @dishes_product.save
      flash[:success] = '菜品创建成功'
      if params[:commit] == '上架并继续新增菜品'
        redirect_to new_admin_dishes_product_path
      else
        redirect_to admin_dishes_products_path
      end
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
      :name, :present_price, :avatar, :categories
    )
    if params[:product].present?
      dishes = dishes.merge(params.require(:product).permit(
      product_inventories_attributes: [
        :id, :price, :share_amount_total, :privilege_amount, :share_amount_lv_1,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
      ))
    end
    dishes
  end
end
