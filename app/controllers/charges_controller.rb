class ChargesController < ApplicationController
  def create
    result = ''
    begin
      result = ChargeService.create_charge(params, request)
    ensure
      render json: result
    end
  end

  def pingpp_callback
    result = 'fail'
    begin
      result = ChargeService.handle_pingpp_callback(params)
    ensure
      render text: result
    end
  end

  # result=success&out_trade_no=19238484
  def success
    @order = Order.find_by(number: params[:out_trade_no])
    @order.check_paid?
  end

  def failure
    @order = Order.find_by(number: params[:out_trade_no])
  end

end
