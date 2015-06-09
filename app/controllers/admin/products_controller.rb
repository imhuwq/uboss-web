#encoding:utf-8
#自定义管理系统
class Admin::ProductsController < AdminController
	def index
    products = Product.where(:user_id=>current_user.id).order("updated_at DESC")
    @products = products.paginate(:page => (params[:page] || 1), :per_page => 10)
    @statistics = {}
    @statistics[:create_today] = products.where('created_at > ? and created_at < ?',Time.now.beginning_of_day,Time.now.end_of_day).count
    @statistics[:count] = products.count
    @statistics[:not_enough] = products.where('count < ?',10).count
	end

	def show
    @product = Product.find_by_id(params[:id])
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
      flash[:success] = "产品创建成功"
    else
      flash[:error] = "#{product.errors.messages}"
      render 'new'
      return
    end
    redirect_to :action=>:index
	end

	def edit
    @product = Product.find_by_id(params[:id])
	end

	def update
    product = Product.find_by_id(params[:id])
    if product.present? and product.user_id == current_user.id and product.update_attributes(product_params)
      
      flash[:success] = "保存成功"
    else
      flash[:error] = "保存失败。#{product.errors.messages}"
    end
    redirect_to :action=>:show,:id=>product.id
	end

  def destroy
    product = Product.find_by_id(params[:id])
    if product.present? and product.user_id == current_user.id and product.destroy
      
      flash[:success] = "删除成功"
    else
      flash[:error] = "无法删除。"
    end
    redirect_to :action=>:index
  end

  private
  def product_params
    params.require(:product).permit(:name,:original_price,
        :present_price,:count,:asset_img,:content,
        :buyer_lv_1,:buyer_lv_2,:buyer_lv_3,:sharer_lv_1,
        :buyer_present_way,:sharer_present_way,:buyer_pay, :traffic_expense
        )
  end

end