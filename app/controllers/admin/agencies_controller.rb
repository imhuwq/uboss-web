class Admin::AgenciesController < AdminController

  before_action :check_new_supplier

  def index 
    authorize! :read, :agencies
    @cooperations = current_user.cooperations.includes(:supplier, :agency).page(params[:page])
    @statistics = {}
    @statistics[:count] = @cooperations.total_count
  end
  
  def new
    authorize! :new, :agency
    @agencies = User.role('agency')
  end

  def build_cooperation_with_auth_code
    authorize! :build_cooperation_with_auth_code, :agency
    if captcha = MobileCaptcha.find_by(code: params[:mobile_auth_code], captcha_type: 'invite_agency', sender_id: current_user.id)
      mobile = captcha.mobile
      if MobileCaptcha.auth_code(mobile, params[:mobile_auth_code], 'invite_agency')
        if user = User.find_by(login: mobile)
          user
        else
          user = User.new(login: mobile, nickname: mobile, mobile: mobile, password: Devise.friendly_token, need_reset_password: true)
          user.save(validate: false)
          user.add_role('seller')
          user.add_role('agency')
          user
        end

        csh = CaptchaSendingHistory.find_by(code: params[:mobile_auth_code], sender_id: current_user.id, receiver_mobile: mobile, invite_type: 1)

        if csh.update_attributes(receiver_id: user.id) and current_user.cooperations.create(agency_id: user.id)
          captcha.destroy
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

  def build_cooperation_with_agency_id
    authorize! :build_cooperation_with_agency_id, :agency
    @agency = User.find_by(id: params[:cooperation][:agency_id])
    unless current_user.has_cooperation_with_agency?(@agency)
      current_user.cooperations.create(agency_id: @agency.id)
    end
    respond_to do |format|
      format.js { render 'build_cooperation' }
    end
  end

  def end_cooperation
    authorize! :end_cooperation, :agency
    @agency = User.find_by(id: params[:cooperation][:agency_id])
    @agency = User.find_by(id: params[:id])
    if current_user.has_cooperation_with_agency?(@agency)
      current_user.cooperations.find_by(agency_id: params[:id]).destroy
    end
    respond_to do |format|
      format.js
    end
  end

end
