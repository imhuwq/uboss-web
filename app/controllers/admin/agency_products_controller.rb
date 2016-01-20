class Admin::AgencyProductsController < AdminController

  before_action :set_product
  before_action :copy_product, only: [:store_supplier_product, :list_supplier_product]

  def valid_agent_products
    ids = current_user.suppliers.pluck(:id)
    p_ids = current_user.agency_products.pluck(:parent_id)
    @products = SupplierProduct.supplied.where(user_id: ids).where.not(id: p_ids)
  end

  def store_supplier_product
    @product_copy
  end

  def list_supplier_product
    @product_copy.published!
    @product_copy
  end

  private

  def set_product
    @product = SupplierProduct.find_by(id: params[:id])
  end

  def copy_product
    @product_copy = @product.amoeba_dup
    @product_copy.user_id = current_user.id
    @product_copy.save
  end

end