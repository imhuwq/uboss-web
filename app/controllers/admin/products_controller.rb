# encoding:utf-8
# 自定义管理系统
class Admin::ProductsController < AdminController
  def index
    products = Product.accessible_by(current_ability).where(status: [0,1]).order('created_at DESC')
    @products = products.page(params[:page] || 1)
    @statistics = {}
    @statistics[:create_today] = products.where('created_at > ? and created_at < ?', Time.now.beginning_of_day, Time.now.end_of_day).count
    @statistics[:count] = products.count
    @statistics[:not_enough] = products.where('count < ?', 10).count
  end

  def show
    @product = Product.find_by_id(params[:id])
    redirect_to action: :index unless @product.present?
  end

  def new
    @product = Product.new
  end

  def create
    product = Product.new(product_params)
    img = AssetImg.new
    img.avatar = params[:asset_img]
    product.asset_img = img
    product.user_id = current_user.id
    if product.save
      flash[:success] = '产品创建成功'
    else
      flash[:error] = "#{product.errors.messages}"
      render 'new'
      return
    end
    redirect_to action: :show, id: product.id
  end

  def edit
    @product = Product.find_by_id(params[:id])
    redirect_to action: :index unless @product.present?
  end

  def update
    product = Product.find_by_id(params[:id])
    img = AssetImg.new
    img.avatar = params[:asset_img]
    product.asset_img = img
    if product.present? && product.user_id == current_user.id && product.update_attributes(product_params)

      flash[:success] = '保存成功'
    else
      flash[:error] = "保存失败。#{product.errors.messages}"
    end
    redirect_to action: :show, id: product.id
  end

  def change_status
    @product = Product.find_by_id(params[:id])
    if @product.status == 0 && !(params[:delete] == 'true')
      @product.status = 1
      flash[:success] = '上架成功'
    elsif @product.status == 1 && !(params[:delete] == 'true')
      @product.status = 0
      flash[:success] = '取消上架成功'
    elsif params[:delete] == 'true'
      @product.status = 2
      flash[:success] = '删除成功'
    end
    @product.save
    respond_to do |format|
      format.html { redirect_to action: :show, id: @product.id }
      format.js do
        products = Product.where(user_id: current_user.id, status: [0,1]).order('created_at DESC')
        @products = products.page(params[:page] || 1)
      end
    end
  end

  def pre_view
    @product = Product.find_by_id(params[:id])
    render layout: 'application'
  end

  private

  def product_params
    params.require(:product).permit(:name, :original_price,
                                    :present_price, :count, :asset_img, :content,
                                    :has_share_lv, :calculate_way,
                                    :share_amount_total, :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
                                    :share_rate_total, :share_rate_lv_1, :share_rate_lv_2, :share_rate_lv_3,
                                    :buyer_pay, :traffic_expense
                                   )
  end
end
