class MobileCaptchasController < ApplicationController

  def create
    invoke_captcha_sending
  end

  def send_with_captcha
    if simple_captcha_valid?
      invoke_captcha_sending
    else
      render json: { message: '验证码错误' }, status: :failure
    end
  end

  private

  def invoke_captcha_sending
    if params[:captcha_type] == 'invite_agency'
      result = MobileCaptcha.send_captcha_with_mobile(params[:mobile], params[:captcha_type], current_user.id)
    else
      result = MobileCaptcha.send_captcha_with_mobile(params[:mobile])
    end

    if result[:success]
      mc = result[:mobile_auth_code]
      #目前只在邀请代销的时候才创建邀请码发送历史记录
      if mc.captcha_type == 'invite_agency'
        receiver_id = User.find_by(login: mc.mobile).try(:id)
        CaptchaSendingHistory.create(code: mc.code, code_sent_at: mc.created_at, code_expired_at: mc.expire_at, sender_id: mc.sender_id, receiver_id: receiver_id, receiver_mobile: mc.mobile, invite_type: mc.captcha_type, invite_status: 'already_sent')
      end
    end

    status = result[:success] ? :ok : :bad_request

    render json: {
      message: model_errors(result[:mobile_auth_code])
    }, status: status
  end

end
