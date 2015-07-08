class MobileAuthCodeController < ApplicationController
  def create
    if mobile = params[:mobile]
      # FIXME handle fail message
      begin
        send_message = MobileAuthCode.send_captcha_with_mobile(mobile)
      rescue Exception => e
        @error = e
      end
      puts @error if @error
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render nothing: true }
    end
  end
end
