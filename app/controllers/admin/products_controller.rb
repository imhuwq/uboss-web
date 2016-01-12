class Admin::ProductsController < AdminController

  load_and_authorize_resource except: [:new_supplier_product, :create_supplier_product, :show_supplier_product, :edit_supplier_product, :update_supplier_product]

  before_action :set_product, only: [:show_supplier_product, :edit_supplier_product, :update_supplier_product]

  def select_carriage_template
    @carriage = CarriageTemplate.find(params[:tpl_id]) if params[:tpl_id].present?
  end

  def refresh_carriage_template
    @carriages = current_user.carriage_templates
  end

  def index
    @products = current_user.products.normal.available.order('products.created_at DESC')
    @products = @products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = @products.where('products.created_at > ? and products.created_at < ?', Time.now.beginning_of_day, Time.now.end_of_day).count
    @statistics[:count] = @products.count
    @statistics[:not_enough] = @products.where('count < ?', 10).count
  end

  def supplier_index
    @products = current_user.products.supplied.order('products.created_at DESC')
    @products = @products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = @products.where('products.created_at > ? and products.created_at < ?', Time.now.beginning_of_day, Time.now.end_of_day).count
    @statistics[:count] = @products.count
    @statistics[:not_enough] = @products.where('count < ?', 10).count
  end

  def create
    if @product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show, id: @product.id
    else
      flash[:error] = "#{@product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def new_supplier_product
    @product = Product.new
    @product.build_supplier_product_info
    authorize! :new_supplier_product, @product
  end

  def create_supplier_product
    @product = current_user.products.new(product_params)
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
    authorize! :show_supplier_product, @product
  end

  def update_supplier_product
    authorize! :update_supplier_product, @product
    if @product.update(product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show_supplier_product, id: @product.id
    else
      flash[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
      render :edit_supplier_product
    end
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

  def edit_supplier_product
    authorize! :edit_supplier_product, @product
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

  

  private

  def set_product
    @product = Product.find_by(id: params[:id])
  end

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def product_params
    params["product"]["supplier_product_info_attributes"]["supplier_id"] = current_user.id if params["product"]["supplier_product_info_attributes"].present?
    params.require(:product).permit(
      :name,      :original_price,  :present_price,     :count,
      :content,   :has_share_lv,    :calculate_way,     :avatar,
      :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :categories,
      :full_cut, :full_cut_number, :full_cut_unit,
      product_inventories_attributes: [
        :id, :price, :count, :share_amount_total, :privilege_amount,
        :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
        sku_attributes: product_propertys_params[:product_propertys_names],
        supplier_product_inventory_attributes: [
          :cost_price, :suggest_price_lower, :suggest_price_upper, :for_sale
        ]
      ],
      supplier_product_info_attributes: [
        :content, :cost_price, :suggest_price_lower, :suggest_price_upper, :supplier_id
      ]
    )
  end
end
