class Api::V1::Admin::VerifyCodesController < ApiBaseController

  before_action :find_orders, only: [:verify_history, :receipt_history]

  def verify
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      verify_code = VerifyCode.find_by(code: params[:code])
      product = verify_code.order_item.product
      render json: { product_name: product.name, product_price: product.present_price, inventories: product.seling_inventories }
    else
      render_error :verify_faild
    end
  end

  def verify_history
    unless orders.nil?
      orders.each do |order|
        order_item = order.order_item
        product = order_item.product
        code = order_item.verify_codes.where(verified: true)
        history << { product_name: product.name, verify_code: code, exchange_time: order.created_at, pay_amount: order.pay_amount, paid_amount: order.paid_amount }
      end
    end
    render json: history
  rescue => e
    render_error :wrong_params
  end

  def receipt_history
    unless orders.nil?
      orders.each do |order|
        history << { buyer_name: order.username, exchange_time: order.created_at, pay_amount: order.pay_amount, paid_amount: order.paid_amount }
      end
    end
    render json: history
  rescue => e
    render_error :wrong_params
  end

  private

  def find_orders
    date = params[:date]
    orders = ServiceOrder.where(created_at: date, seller_id: current_user.id)
    history = []
  end

end
