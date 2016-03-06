class Admin::SupplierProductsController < AdminController

  load_and_authorize_resource except: :create

  before_action :check_new_supplier, except: :show

  def index
    params[:status] ||= 'supply'
    if params[:status] == 'supply'
      @supplier_products = current_user.supplier_products.supplied.order('products.created_at DESC')
    elsif params[:status] == 'store'
      @supplier_products = current_user.supplier_products.stored.order('products.created_at DESC')
    elsif params[:status] == 'delete'
      @supplier_products = current_user.supplier_products.deleted.order('products.created_at DESC')
    end
    @supplier_products = @supplier_products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:count] = @supplier_products.count
  end
  
  def new
  end

  def create
    @supplier_product = SupplierProduct.new(user_id: current_user.id)
    supplier_product_info = @supplier_product.build_supplier_product_info
    supplier_product_info.build_description
    @supplier_product.assign_attributes supplier_product_params
    authorize! :create, @supplier_product
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
    if @supplier_product.update(supplier_product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show, id: @supplier_product.id
    else
      flash[:error] = "保存失败。#{@supplier_product.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def toggle_supply_status
    supplier_product_info = @supplier_product.supplier_product_info
    begin
      if params[:status] == 'store'
        @supplier_product.stored
        @notice = '下架成功'
      elsif params[:status] == 'supply'
        @supplier_product.supplied
        @notice = '上架成功'
      elsif params[:status] == 'delete'
        @supplier_product.deleted
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
      product_collection = supplier_product_info.deleted? ? [] : [@supplier_product]
      render(partial: 'admin/supplier_products/products', locals: { products: product_collection })
    else
      flash[:success] = @notice
      flash[:error] = @error
      redirect_to action: :show, id: @supplier_product.id
    end
  end

  private

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def supplier_product_params
    params['supplier_product'].merge!(params['product']) if params[:product].is_a?(Hash)
    params['supplier_product'].merge!(params['ordinary_product']) if params[:ordinary_product].is_a?(Hash)
    params['supplier_product']['supplier_product_inventories_attributes'] = params['supplier_product']['product_inventories_attributes']
    params.require(:supplier_product).permit(
      :name, :content, :has_share_lv, :calculate_way, :avatar,
      :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :categories,
      :full_cut, :full_cut_number, :full_cut_unit, :count,
      :supply_content, :cost_price, :suggest_price_lower, :suggest_price_upper,
      supplier_product_inventories_attributes: [
        :id, :share_amount_total, :privilege_amount,
        :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
        :cost_price, :suggest_price_lower, :suggest_price_upper, :sale_to_agency, :quantity, :count,
        sku_attributes: product_propertys_params[:product_propertys_names]
      ],
    )
  end
end
