class Admin::ServiceProductsController < AdminController

  load_and_authorize_resource

  def index
    @service_products = current_user.service_products.available.order('created_at DESC')
    @service_products = @service_products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = @service_products.where('created_at > ? and created_at < ?', Time.now.beginning_of_day, Time.now.end_of_day).count
    @statistics[:count] = @service_products.count
    @statistics[:not_enough] = @service_products.where('count < ?', 10).count
  end

  def create
    @service_product.user_id = current_user.id
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
      # if @product.user.authenticated?
        @service_product.status = 'published'
        @service_notice = '上架成功'
      # else
      #   @error = '该帐号还未通过身份验证，请先验证:点击右上角用户名，进入“个人/企业认证”'
      # end
    elsif params[:status] == 'unpublish'
      @service_product.status = 'unpublish'
      @notice = '取消上架成功'
    elsif params[:status] == 'closed'
      @service_product.status = 'closed'
      @notice = '删除成功'
    end

    if not @service_product.save
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

  def service_product_params
    params.require(:service_product).permit(
      :name,  :service_type, :original_price, :present_price,
      :count, :avatar, :content, :monthes,    :short_description
    )
  end
end
