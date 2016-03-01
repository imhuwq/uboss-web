module Admin::ProductsHelper

  def can_manage_seller_product(product)
    can? :manage, product and (product.type == "OrdinaryProduct" or product.type == "AgencyProduct")
  end

  def can_agent_product(product)
    current_user.is_agency? and can? :store_or_list_supplier_product, product and product.type == "SupplierProduct"
  end
  
  def can_manage_supplier_product(product)
    can? :manage, product and product.type == "SupplierProduct"
  end

  def the_product_path(product)
    if product.type == "SupplierProduct"
      admin_supplier_product_path(product)
    else
      admin_product_path(product)
    end
  end

end
