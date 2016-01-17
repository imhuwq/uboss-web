class Admin::SupplierProductsController < AdminController

  load_and_authorize_resource except: :create

  def index
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
  
  def new
  end

  def create
    @supplier_product = SupplierProduct.new(user_id: current_user.id)
    supplier_product_info = @supplier_product.build_supplier_product_info
    supplier_product_info.build_description
    @supplier_product.assign_attributes supplier_product_params
    authorize! :manage, @supplier_product
    if @supplier_product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show, id: @supplier_product.id
    else
      flash[:error] = "#{@supplier_product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show, id: @product.id
    else
      flash[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
      render :edit
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

  def supplier_product_params
    params['supplier_product'].merge!(params['product'])
    params['supplier_product']['supplier_product_inventories_attributes'] = params['supplier_product']['product_inventories_attributes']
    params.require(:supplier_product).permit(
      :name, :content, :has_share_lv, :calculate_way, :avatar,
      :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :categories,
      :full_cut, :full_cut_number, :full_cut_unit,
      :supply_content, :cost_price, :suggest_price_lower, :suggest_price_upper,
      supplier_product_inventories_attributes: [
        :id, :share_amount_total, :privilege_amount,
        :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
        :cost_price, :suggest_price_lower, :suggest_price_upper, :sale_to_agency, :quantity,
        sku_attributes: product_propertys_params[:product_propertys_names]
      ],
    )
  end
end
