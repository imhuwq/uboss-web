class Admin::EnterpriseAuthenticationsController < AdminController
  def new
    if EnterpriseAuthentication.find_by(user_id: current_user).present?
      flash.now[:alert] = '您的验证信息已经提交，请检查。'
      redirect_to action: :show
    else
      @enterprise_authentication = EnterpriseAuthentication.new
    end
  end

  def show
    @enterprise_authentication = EnterpriseAuthentication.find_by(user_id: current_user)
    unless @enterprise_authentication.present?
      flash.now[:notice] = '您还没有认证'
      redirect_to action: :new
    end
  end

  def edit
    enterprise_authentication = EnterpriseAuthentication.find_by!(user_id: current_user)
    if [:review, :pass].include?(enterprise_authentication.status)
      flash.now[:alert] = '当前状态不允许修改。'
      redirect_to action: :show
    else
      @enterprise_authentication = enterprise_authentication
    end
  end

  def create
    valid_create_params
    @enterprise_authentication = EnterpriseAuthentication.new(allow_params)
    if @errors.present?
      flash.now[:error] = @errors.join("\n")
      render 'new'
      return
    else
      @enterprise_authentication.user_id = params[:user_id]
      @enterprise_authentication.business_license_img = params[:business_license_img]
      @enterprise_authentication.legal_person_identity_card_front_img = params[:legal_person_identity_card_front_img]
      @enterprise_authentication.legal_person_identity_card_end_img = params[:legal_person_identity_card_end_img]
      if @enterprise_authentication.save
        flash.now[:success] = '保存成功'
        redirect_to action: :show
      else
        flash.now[:error] = "保存失败：#{@enterprise_authentication.errors}"
        render 'new'
      end
    end
  end

  def update
    valid_update_params
    if @errors.present?
      flash.now[:error] = @errors.join("\n")
      redirect_to action: :edit
      return
    else
      @enterprise_authentication = EnterpriseAuthentication.find_by!(user_id: current_user)
      @enterprise_authentication.update_attributes(allow_params)
      @enterprise_authentication.business_license_img = params[:business_license_img] if params[:business_license_img]
      @enterprise_authentication.legal_person_identity_card_front_img = params[:legal_person_identity_card_front_img] if params[:legal_person_identity_card_front_img]
      @enterprise_authentication.legal_person_identity_card_end_img = params[:legal_person_identity_card_end_img] if  params[:legal_person_identity_card_end_img]
      if @enterprise_authentication.save
        flash.now[:success] = '保存成功'
        redirect_to action: :show
      else
        flash.now[:error] = "保存失败：#{@enterprise_authentication.errors}"
        redirect_to action: :edit
      end
    end
  end

  private

  def allow_params
    params.require(:enterprise_authentication).permit(:mobile, :address, :enterprise_name, :mobile_auth_code)
  end

  def valid_create_params
    @errors = []
    hash = {
      '验证码错误或已过期。': MobileAuthCode.auth_code(allow_params[:mobile], allow_params[:mobile_auth_code]),
      '营业执照不能为空。': params[:business_license_img],
      '身份证照片正面不能为空。': params[:legal_person_identity_card_front_img],
      '身份证照片反面不能为空。': params[:legal_person_identity_card_end_img],
      '公司名不能为空。': allow_params[:enterprise_name],
      '地址不能为空。': allow_params[:address],
      '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
    }
    hash.each do |k, v|
      @errors << k unless v.present?
    end
  end

  def valid_update_params
    hash = {
      '验证码错误或已过期。': MobileAuthCode.auth_code(allow_params[:mobile], allow_params[:mobile_auth_code]),
      '公司名不能为空。': allow_params[:enterprise_name],
      '地址不能为空。': allow_params[:address],
      '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
    }
    hash.each do |k, v|
      @errors << k unless v.present?
    end
  end
end
