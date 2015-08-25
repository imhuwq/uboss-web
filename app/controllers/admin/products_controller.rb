# encoding:utf-8
# 自定义管理系统
class Admin::ProductsController < AdminController

  load_and_authorize_resource

  def index
    @products = Product.accessible_by(current_ability).where(status: [0,1]).order('created_at DESC')
    @products = @products.page(params[:page] || 1)
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
    if @product.present? && @product.user_id == current_user.id && @product.update(product_params)
      flash[:success] = '保存成功'
    else
      flash[:error] = "保存失败。#{@product.errors.full_messages.join('<br/>')}"
    end
    redirect_to action: :show, id: @product.id
  end

  def change_status
    if params[:status] == 'published'
      if @product.user.authenticated?
        @product.status = 'published'
        flash[:success] = '上架成功'
      else
        flash[:notice] = '该帐号还未通过身份样子，请先验证:点击右上角用户名，进入“个人/企业认证”'
      end
    elsif params[:status] == 'unpublish'
      @product.status = 'unpublish'
      flash[:success] = '取消上架成功'
    elsif params[:status] == 'closed'
      @product.status = 'closed'
      flash[:success] = '删除成功'
    end
    @product.save
    respond_to do |format|
      format.html { redirect_to action: :show, id: @product.id }
      format.js do
        products = Product.accessible_by(current_ability).where(status: [0,1]).order('created_at DESC')
        @products = products.page(params[:page] || 1)
      end
    end
  end

  def pre_view
    @seller = @product.user
    render layout: 'application'
  end

  private

  def product_params
    params.require(:product).permit(
      :name,               :original_price,    :present_price, :count,
      :content,            :has_share_lv,      :calculate_way, :avatar,
      :share_amount_total, :share_amount_lv_1, :share_amount_lv_2,
      :share_amount_lv_3,  :share_rate_total,  :share_rate_lv_1,
      :share_rate_lv_2,    :share_rate_lv_3,   :buyer_pay,
      :traffic_expense,    :short_description
    )
  end
end
