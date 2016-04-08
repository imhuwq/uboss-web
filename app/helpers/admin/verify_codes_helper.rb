module Admin::VerifyCodesHelper
  def verify_code_target_url(verify_code)
    if verify_code.target_type == 'DishesOrder'
      admin_dishes_product_path(get_product(verify_code))
    else
      admin_service_product_path(get_product(verify_code))
    end
  end

  def get_product(verify_code)
    if verify_code.target_type == 'DishesOrder'
      verify_code.target.order_item.product
    else
      verify_code.order_item.product
    end
  end
end
