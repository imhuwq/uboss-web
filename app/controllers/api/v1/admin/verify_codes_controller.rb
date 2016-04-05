class Api::V1::VerifyCodesController < ApiBaseController

  def verify
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      verify_code = VerifyCode.find_by(code: params[:code])
      product = verify_code.order_item.product
      render json: { product_name: product.name, product_price: product.price, inventories: product.seling_inventories }
    else
      render_error :verify_faild
    end
  end

end
