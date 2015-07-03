class MobileAuthCodeController < ApplicationController
  def create
  	puts params
  	mobile = params[:mobile]
    if mobile.present?
      if User.find_by_mobile(mobile).present?
      	MobileAuthCode.find_by_mobile(mobile).destroy
      	MobileAuthCode.create(mobile: mobile)
      else
        User.create_guest(mobile)
        MobileAuthCode.find_by_mobile(mobile).destroy
        MobileAuthCode.create(mobile: mobile)
      end
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render nothing: true }
    end
  end
end
