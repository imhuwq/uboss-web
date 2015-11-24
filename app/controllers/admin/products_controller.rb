class Admin::ProductsController < AdminController

  load_and_authorize_resource

  def select_carriage_template
    @carriage = CarriageTemplate.find(params[:tpl_id]) if params[:tpl_id].present?
  end

  def index
    @products = current_user.products.available.order('created_at DESC')
    @products = @products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = @products.where('created_at > ? and created_at < ?', Time.now.beginning_of_day, Time.now.end_of_day).count
    @statistics[:count] = @products.count
    @statistics[:not_enough] = @products.where('count < ?', 10).count
  end

  def create
    @product.user_id = current_user.id
    if @product.save
      flash[:success] = '产品创建成功'
      redirect_to action: :show, id: @product.id
    else
      flash[:error] = "#{@product.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    puts params[:categories]
    if @product.update(product_params)
      flash[:success] = '保存成功'
      redirect_to action: :show, id: @product.id
    else
      flash[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
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
      render(partial: 'products', locals: { products: product_collection })
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
    render layout: 'application'
  end

  private

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def product_params
    params.require(:product).permit(
      :name,      :original_price,  :present_price,     :count,
      :content,   :has_share_lv,    :calculate_way,     :avatar,
      :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :categories,
      product_inventories_attributes: [
        :id, :price, :count, :share_amount_total, :privilege_amount,
        :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
    )
  end
end
