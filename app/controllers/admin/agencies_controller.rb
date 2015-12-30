class Admin::AgenciesController < AdminController

  def my_agencies
    @agencies = current_user.agencies
  end
  
  def new_agency
  end

  def build_cooperation
    if captcha = MobileCaptcha.find_by(code: params[:mobile_auth_code], captcha_type: 'invite_agency', sender_id: current_user.id)
      mobile = captcha.mobile
      if MobileCaptcha.auth_code(mobile, params[:mobile_auth_code], 'invite_agency')
        if user = User.find_by(login: mobile)
          user
        else
          user = User.new(login: mobile)
          user.save(validate: false)
          user.user_roles << UserRole.find_by(name: 'seller')
          user
        end

        if current_user.cooperations.create!(agency_id: user.id)
          captcha.destroy!
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
