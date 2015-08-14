class MobileAuthCodeController < ApplicationController
  def create
    if mobile = params[:mobile]
      # FIXME handle fail message
      begin
        MobileAuthCode.send_captcha_with_mobile(mobile)
      rescue => e
        Airbrake.notify_or_ignore(e, parameters: {mobile: mobile}, cgi_data: ENV.to_hash)
      end
    end
    render json: {success: !@error.present?}, status: @error.present? ? :failure : :ok
  end
end
