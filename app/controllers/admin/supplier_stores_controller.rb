class Admin::SupplierStoresController < AdminController

  before_action :set_supplier_store, except: :show
  authorize_resource

  def new
  end

  def create
    @supplier_store.build_supplier_store_info
    @supplier_store.attributes = supplier_store_params
    if @supplier_store.save and current_user.add_role('supplier')
      flash[:success] = '恭喜，创建供货店铺成功！'
      redirect_to edit_info_admin_supplier_store_path
    else
      flash[:error] = @supplier_store.errors.full_messages.join(', ')
      redirect_to :back
    end
  end

  def edit_info
  end

  def update_info
    @result = @supplier_store.update_attributes(supplier_store_params)
    respond_to do |format|
      format.js
      format.html {
        if @result
          flash[:success] = '完善客服信息成功！'
          redirect_to admin_agencies_path
        else
          flash[:error] = @supplier_store.errors.full_messages.join(', ')
          redirect_to :back
        end
      }
    end
  end

  def update_name
    @supplier_store.update_attributes(store_name: params[:supplier_store][:store_name])
    respond_to do |format|
      format.js
    end
  end

  def update_short_description
    @supplier_store.update_attributes(store_short_description: params[:supplier_store][:store_short_description])
    respond_to do |format|
      format.js
    end
  end

  def update_store_cover
    if @supplier_store.update_attributes(store_cover: params[:avatar])
      @message = { message: '上传成功！' }
    else
      @message = { message: '上传失败' }
    end
    render json:  @message
  end

  def destroy
    if current_user.remove_role('supplier') and @supplier_store.destroy
      flash[:success] = '成功解除供应商身份！'
    else
      flash[:error] = '解除供应商身份失败！'
    end
    redirect_to :back
  end

  def show
    @supplier_store = SupplierStore.find_by(id: params[:id])
    @supplier_products = @supplier_store.supplier.supplier_products.supplied.order('products.created_at DESC')
    @supplier_products = @supplier_products.includes(:asset_img).page(params[:page] || 1)
    @statistics = {}
    @statistics[:products_count] = @supplier_products.count
    @statistics[:agencies_count] = @supplier_store.supplier.agencies.count
  end

  private

  def supplier_store_params
    params.require(:supplier_store).permit(:store_name, :province, :city, :area, :guess_province, :guess_city, :phone_number, :wechat_id)
  end

  def set_supplier_store
    @supplier_store = current_user.supplier_store || current_user.build_supplier_store 
  end

end
