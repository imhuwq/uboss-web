class Admin::EnterpriseAuthenticationsController < AdminController
  def index
    if super_admin?
      @enterprise_authentications = EnterpriseAuthentication.order("updated_at DESC").page(params[:page] || 1)
    else
      flash[:notice] = "需要管理员权限"
      redirect_to action: :show
    end
  end

  def new
    if EnterpriseAuthentication.find_by(user_id: current_user).present?
      flash[:alert] = '您的验证信息已经提交，请检查。'
      redirect_to action: :show
    else
      @enterprise_authentication = EnterpriseAuthentication.new
    end
  end

  def show
    @enterprise_authentication = EnterpriseAuthentication.find_by(user_id: current_user)
    unless @enterprise_authentication.present?
      flash[:notice] = '您还没有认证'
      redirect_to action: :new
    end
  end

  def edit
    enterprise_authentication = EnterpriseAuthentication.find_by!(user_id: current_user)
    if [:review, :pass].include?(enterprise_authentication.status)
      flash[:alert] = '当前状态不允许修改。'
      redirect_to action: :show
    else
      @enterprise_authentication = enterprise_authentication
    end
  end

  def create
    valid_create_params
    @enterprise_authentication = EnterpriseAuthentication.new(allow_params)
    @enterprise_authentication.user_id = current_user.id
    if @errors.present?
      flash[:error] = @errors.join("\n")
      render 'new'
      return
    else
      @enterprise_authentication.user_id = params[:user_id]
      @enterprise_authentication.business_license_img = params[:business_license_img]
      @enterprise_authentication.legal_person_identity_card_front_img = params[:legal_person_identity_card_front_img]
      @enterprise_authentication.legal_person_identity_card_end_img = params[:legal_person_identity_card_end_img]
      if @enterprise_authentication.save
        flash[:success] = '保存成功'
        redirect_to action: :show
      else
        flash[:error] = "保存失败：#{@enterprise_authentication.errors.full_messages.join('<br/>')}"
        render 'new'
      end
    end
  end

  def update
    valid_update_params
    if @errors.present?
      flash[:error] = @errors.join("\n")
      redirect_to action: :edit
      return
    else
      @enterprise_authentication = EnterpriseAuthentication.find_by!(user_id: current_user)
      @enterprise_authentication.update_attributes(allow_params)
      @enterprise_authentication.business_license_img = params[:business_license_img] if params[:business_license_img]
      @enterprise_authentication.legal_person_identity_card_front_img = params[:legal_person_identity_card_front_img] if params[:legal_person_identity_card_front_img]
      @enterprise_authentication.legal_person_identity_card_end_img = params[:legal_person_identity_card_end_img] if  params[:legal_person_identity_card_end_img]
      if @enterprise_authentication.save
        flash[:success] = '保存成功'
        redirect_to action: :show
      else
        flash[:error] = "保存失败：#{@enterprise_authentication.errors.full_messages.join('<br/>')}"
        redirect_to action: :edit
      end
    end
  end

  def change_status
    @enterprise_authentication = EnterpriseAuthentication.find_by(user_id: params[:user_id])
    if @enterprise_authentication.present? && params[:status]
      @enterprise_authentication.status = params[:status]
      if params[:status] == "pass"
        @enterprise_authentication.check_and_set_user_authenticated_to_yes
      else
        @enterprise_authentication.check_and_set_user_authenticated_to_no
      end

      if @enterprise_authentication.save
        flash.now[:success] = '状态被修改'
      else
        @enterprise_authentication.valid?
        flash.now[:error] = "保存失败：#{@enterprise_authentication.errors.full_messages.join('<br/>')}"
      end
    end

    respond_to do |format|
      format.html { redirect_to action: :show, user_id: @enterprise_authentication.user_id }
      format.js do
        @enterprise_authentications = EnterpriseAuthentication.order("updated_at DESC").page(params[:page] || 1)
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
