class Admin::AgencyProductsController < AdminController

  before_action :copy_product, only: [:store_supplier_product, :list_supplier_product]

  def valid_agent_products
    authorize! :valid_agent_products, SupplierProduct
    ids = current_user.suppliers.pluck(:id)
    p_ids = current_user.agency_products.where.not(status: 2).pluck(:parent_id)
    @products = SupplierProduct.supplied.where(user_id: ids).where.not(id: p_ids).page(params[:page])
  end

  def store_supplier_product
  end

  def list_supplier_product
    @product_copy.try(:published!)
  end

  private

  def copy_product
    @product = SupplierProduct.find_by(id: params[:id])
    authorize! :store_or_list_supplier_product, @product
    unless @product.has_been_agented_by?(current_user)
      @product_copy = @product.amoeba_dup
      @product_copy.user_id = current_user.id
      @product_copy.save
    end
  rescue CanCan::AccessDenied
    @denied = true
  end

end
