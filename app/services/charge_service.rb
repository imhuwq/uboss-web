require 'pingpp'

module ChargeService
  APP_ID = Rails.application.secrets.pingpp_app_id

  extend self

  def create_charge(params, request)
    order = Order.find(params[:order_id])
    open_id = 'nil' #current_user.open_id
    client_ip = request.remote_ip
    channel = params[:channel].downcase
    begin
      ch = Pingpp::Charge.create(
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
      ch.to_json
    rescue Pingpp::PingppError => error
      error.http_body
    end
  end

  def handle_pingpp_callback(params)
    return 'fail' if params[:object].blank?

    case params[:object]
    when 'charge'
      'success'
      charge_success(params)
    when 'refund'
      'success'
    else
      'fail'
    end
  end

  private

  def charge_success(params)
    #TODO handle charge_success
  end

  def generate_extra(channel)
    case channel
    when 'alipay_wap'
      extra = {
        'success_url' => 'https://jqczxcrucf.localtunnel.me/charge/success',
        'cancel_url'  => 'https://jqczxcrucf.localtunnel.me/charge/cancel'
      }
    when 'upacp_wap', 'upmp_wap'
      extra = {
        'result_url' => 'https://jqczxcrucf.localtunnel.me/charge/result?code='
      }
    when 'bfb_wap'
      extra = {
        'bfb_login' => true,
        'result_url' => 'https://jqczxcrucf.localtunnel.me/charge/success'
      }
    when 'wx_pub'
      extra = {
        'trade_type' => 'JSAPI',
        'open_id' => open_id
      }
    end
  end

end
