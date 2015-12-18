class Admin::ServiceProductsController < AdminController

  load_and_authorize_resource

  def new
    @service_product = ServiceProduct.new
  end

  def index
    @service_products = account_service_products(params[:type]).available.order('created_at DESC')
    @service_products = @service_products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:count] = @service_products.count
    @statistics[:published] = @service_products.where(status: 1).count
    @statistics[:unpublish] = @service_products.where(status: 0).count
  end

  def create
    @service_product = ServiceProduct.new(service_product_params)
    @service_product.user_id = current_user.id
    @service_product.service_store = current_user.service_store
    if @service_product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show, id: @service_product.id
    else
      flash[:error] = "#{@service_product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    if @service_product.update(service_product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show, id: @service_product.id
    else
      flash[:error] = "保存失败。#{@service_product.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def change_status
    if params[:status] == 'published'
        @service_product.status = 'published'
        @notice = '上架成功'
    elsif params[:status] == 'unpublish'
      @service_product.status = 'unpublish'
      @notice = '取消上架成功'
    elsif params[:status] == 'closed'
      @service_product.status = 'closed'
      @notice = '删除成功'
    end

    unless @service_product.save
      @error = model_errors(@service_product).join('<br/>')
    end

    if request.xhr?
      flash.now[:success] = @notice
      flash.now[:error] = @error
      product_collection = @service_product.closed? ? [] : [@service_product]
      render(partial: 'products', locals: { products: product_collection })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show, id: @service_product.id
    end
  end

  def pre_view
    @seller = @service_product.user
    render layout: 'mobile'
  end

  private

  def account_service_products(type)
    type ||= 'all'
    if ['published', 'unpublish', 'all'].include?(type)
      current_user.service_products.try(type)
    else
      raise "invalid service product type"
    end
  end

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def service_product_params
    params.require(:service_product).permit(
      :name,  :service_type, :original_price, :present_price,
      :count, :avatar, :content, :monthes,    :short_description,
    ).merge(params.require(:product).permit(
      product_inventories_attributes: [
        :id, :price, :count,
        :share_amount_total, :privilege_amount, :share_amount_lv_1,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
    ))
  end
end
