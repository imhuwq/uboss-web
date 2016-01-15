class Admin::ProductsController < AdminController

  load_and_authorize_resource class: 'OrdinaryProduct'

  def select_carriage_template
    @carriage = CarriageTemplate.find(params[:tpl_id]) if params[:tpl_id].present?
  end

  def refresh_carriage_template
    @carriages = current_user.carriage_templates
  end

  def index
    @products = @products.available.order('created_at DESC')
    @products = @products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = @products.create_today.total_count
    @statistics[:count] = @products.total_count
    @statistics[:not_enough] = @products.where('count < ?', 10).total_count
  end

  def new
    @product = OrdinaryProduct.new()
  end

  def create
    @product.ordinary_store = current_user.ordinary_store

    if @product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show, id: @product.id
    else
      flash.now[:error] = "#{@product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    if @product.update(product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show, id: @product.id
    else
      flash.now[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def change_status
    if params[:status] == 'published'
      # if @product.user.authenticated?
        @product.status = 'published'
        @notice = '上架成功'
      # else
      #   @error = '该帐号还未通过身份验证，请先验证:点击右上角用户名，进入“个人/企业认证”'
      # end
    elsif params[:status] == 'unpublish'
      @product.status = 'unpublish'
      @notice = '取消上架成功'
    elsif params[:status] == 'closed'
      @product.status = 'closed'
      @notice = '删除成功'
    end
    if not @product.save
      @error = model_errors(@product).join('<br/>')
    end
    if request.xhr?
      flash.now[:success] = @notice
      flash.now[:error] = @error
      product_collection = @product.closed? ? [] : [@product]
      render(partial: 'products', locals: { products: product_collection, supplier: false })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show, id: @product.id
    end
  end

  def switch_hot_flag
    if @product.update(hot: !@product.hot)
      render json: { hot: @product.hot }
    else
      render json: { message: model_errors(@product) }, status: 422
    end
  end

  def pre_view
    @seller = @product.user
    render layout: 'mobile'
  end

  #supplier products

  def supplier_index
    params[:status] ||= 'supply'
    if params[:status] == 'supply'
      @products = current_user.products.supply.supply_supplied.order('products.created_at DESC')
    elsif params[:status] == 'store'
      @products = current_user.products.supply.supply_stored.order('products.created_at DESC')
    elsif params[:status] == 'delete'
      @products = current_user.products.supply.supply_deleted.order('products.created_at DESC')
    end
    @products = @products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:count] = @products.count
  end
  
  def new_supplier_product
    @product = Product.new
    @product.build_supplier_product_info
    @product.product_inventories.new
    @product.supplier_product_inventories.new
    authorize! :new_supplier_product, @product
  end

  def create_supplier_product
    @product = current_user.products.new(product_params)
    @product.produce_type = 'supply'
    authorize! :create_supplier_product, @product
    if @product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show_supplier_product, id: @product.id
    else
      flash[:error] = "#{@product.errors.full_messages.join('<br/>')}"
      render :new_supplier_product
    end
  end

  def show_supplier_product
  end

  def edit_supplier_product
  end

  def update_supplier_product
    if @product.update(product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show_supplier_product, id: @product.id
    else
      flash[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
      render :edit_supplier_product
    end
  end

  def toggle_supply_status
    supplier_product_info = @product.supplier_product_info
    begin
      if params[:status] == 'store'
        supplier_product_info.stored!
        @notice = '下架成功'
      elsif params[:status] == 'supply'
        supplier_product_info.supplied!
        @notice = '上架成功'
      elsif params[:status] == 'delete'
        supplier_product_info.deleted!
        @notice = '删除成功'
      else
        @error = '未知操作'
      end
    rescue => e
      logger.error e
      @error = '操作失败'
    end
    if request.xhr?
      flash.now[:success] = @notice
      flash.now[:error] = @error
      product_collection = supplier_product_info.deleted? ? [] : [@product]
      render(partial: 'products', locals: { products: product_collection, supplier: true })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show_supplier_product, id: @product.id
    end
  end

  private

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def product_inventories_params
    if params[:product]
      params.require(:product).permit(
        product_inventories_attributes: [
          :id, :price, :count, :share_amount_total, :privilege_amount,
          :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
          sku_attributes: product_propertys_params[:product_propertys_names],
        ]
      )
    else
      { product_inventories_attributes: [] }
    end
  end

  def product_params
    params.require(:ordinary_product).permit(
      :name,      :original_price,  :present_price,     :count,
      :content,   :has_share_lv,    :calculate_way,     :avatar,
      :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :categories,
      :full_cut, :full_cut_number, :full_cut_unit
    ).merge(product_inventories_params)
  end

end
