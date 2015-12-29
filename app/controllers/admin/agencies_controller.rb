class Admin::AgenciesController < AdminController
  
  def new_agency
  end

  def build_cooperation
    if captcha = MobileCaptcha.find_by(code: params[:mobile_auth_code], captcha_type: 'invite_agency', sender_id: current_user.id)
      mobile = captcha.mobile
      if MobileCaptcha.auth_code(mobile, params[:mobile_auth_code], 'invite_agency')
        if user = User.find_by(login: mobile)
          user
        else
          user = User.create!(login: mobile, password: '88888888', password_confirmation: '88888888')
          user.user_roles << UserRole.find_by(name: 'seller')
          user
        end

        if current_user.cooperations.create!(seller_id: user.id)
          render json: nil, status: :created
        else
          render json: { message: '授权失败' }, status: :failure
        end
      else
        render json: { message: '验证码已过期' }, status: :failure
      end
    else
      render json: { message: '验证码错误' }, status: :failure
    end
  end

end
