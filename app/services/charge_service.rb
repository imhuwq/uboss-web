require 'pingpp'

module ChargeService
  APP_ID = Rails.application.secrets.pingpp_app_id

  extend self

  def create_charge(params, request)
    order = Order.find(params[:order_id])
    open_id = 'nil' # TODO current_user.wx_open_id
    client_ip = request.remote_ip
    channel = params[:channel].downcase
    begin
      charge = Pingpp::Charge.create(
        :order_no  => order.number,
        :app       => {'id' => APP_ID},
        :channel   => channel,
        :amount    => order.pay_amount,
        :client_ip => client_ip,
        :currency  => 'cny',
        :subject   => "Charge Subject: order #{order.id}",
        :body      => "Charge Body",
        :extra     => generate_extra(channel)
      )
      create_order_charge(order, charge)
      charge.to_json
    rescue Pingpp::PingppError => error
      error.http_body
    end
  end

  def handle_pingpp_callback(params)
    return 'fail' if params[:object].blank?

    case params[:object]
    when 'charge'
      charge_success(params)
      'success'
    when 'refund'
      'success'
    else
      'fail'
    end
  end

  private

  def create_order_charge order, charge
    order.order_charges.create(channel: charge.channel, charge_id: charge.id)
  end

  def charge_success(params)
    order = Order.find_by(number: params[:order_no])
    if params[:paid] == true
      order.pay!
    end
  end

  def generate_extra(channel)
    case channel
    when 'alipay_wap'
      extra = {
        'success_url' => 'http://uboss.local:3000/charge/success',
        'cancel_url'  => 'http://uboss.local:3000/charge/cancel'
      }
    when 'upacp_wap', 'upmp_wap'
      extra = {
        'result_url' => 'http://uboss.local:3000/charge/result?code='
      }
    when 'bfb_wap'
      extra = {
        'bfb_login' => true,
        'result_url' => 'http://uboss.local:3000/charge/success'
      }
    when 'wx_pub'
      extra = {
        'trade_type' => 'JSAPI',
        'open_id' => open_id
      }
    end
  end

end
