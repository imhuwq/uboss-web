class MobileAuthCodeController < ApplicationController
  def create
    if mobile = params[:mobile]
      MobileAuthCode.send_captcha_with_mobile(mobile)
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render nothing: true }
    end
  end
end
