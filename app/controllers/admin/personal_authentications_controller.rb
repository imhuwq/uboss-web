class Admin::PersonalAuthenticationsController < AdminController

  load_and_authorize_resource

  def index
    @personal_authentications = PersonalAuthentication.accessible_by(current_ability).order("updated_at DESC").page(params[:page] || 1)
  end

  def new
    if PersonalAuthentication.find_by(user_id: current_user).present?
      flash[:alert] = '您的验证信息已经提交，请检查。'
      redirect_to action: :show
    end
  end

  def show
    if current_user.is_super_admin?
      @personal_authentication = PersonalAuthentication.find_by!(user_id:( params[:user_id] || current_user))
    else
      @personal_authentication = PersonalAuthentication.find_by(user_id: current_user)
      unless @personal_authentication.present?
        flash[:notice] = '您还没有认证'
        redirect_to action: :new
      end
    end
  end

  def edit
    personal_authentication = PersonalAuthentication.find_by(user_id: current_user)
    if !personal_authentication.present?
      redirect_to action: :new
    elsif [:review, :pass].include?(personal_authentication.status)
      flash[:alert] = '当前状态不允许修改。'
      redirect_to action: :show
    else
      @personal_authentication = personal_authentication
    end
  end

  def create
    @personal_authentication = PersonalAuthentication.new(personal_authentication_params)
    valid_create_params
    if @errors.present?
      flash[:error] = @errors.join("\n")
      render 'new'
      return
    else
      @personal_authentication.user_id = current_user.id
      if @personal_authentication.save
        MobileAuthCode.find_by(code: personal_authentication_params[:mobile_auth_code]).try(:destroy)
        flash[:success] = '保存成功'
        redirect_to action: :show
      else
        flash[:error] = "保存失败：#{model_errors(@personal_authentication).join('<br/>')}"
        render 'new'
      end
    end
  end

  def update
    valid_update_params
    @personal_authentication = PersonalAuthentication.find_by!(user_id: current_user)
    if @errors.present?
      flash[:error] = @errors.join("\n")
      redirect_to action: :edit
      return
    else
      hash = personal_authentication_params.merge({status: 'posted'})
      if @personal_authentication.update(hash)
        MobileAuthCode.find_by(code: personal_authentication_params[:mobile_auth_code]).try(:destroy)
        flash[:success] = '保存成功'
        redirect_to action: :show
      else
        flash[:error] = "保存失败：#{@personal_authentication.errors.full_messages.join('<br/>')}"
        redirect_to action: :edit
      end
    end
  end

  def change_status
    @personal_authentication = PersonalAuthentication.find_by(user_id: params[:user_id])
    if @personal_authentication.present? && params[:status]
      @personal_authentication.status = params[:status]
      if params[:status] == "pass"
        @personal_authentication.check_and_set_user_authenticated_to_yes
      else
        @personal_authentication.check_and_set_user_authenticated_to_no
      end
      if @personal_authentication.save
        flash.now[:success] = '状态被修改'
      else
        @personal_authentication.valid?
        flash.now[:error] = "保存失败：#{@personal_authentication.errors.full_messages.join('<br/>')}"
      end
    end

    respond_to do |format|
      format.html { redirect_to action: :show, user_id: @personal_authentication.user_id }
      format.js do
        @personal_authentications = PersonalAuthentication.order("updated_at DESC").page(params[:page] || 1)
      end
    end
  end

  private

  def personal_authentication_params
    params.require(:personal_authentication).permit(:mobile, :address, :name,
                  :identity_card_code, :mobile_auth_code, :face_with_identity_card_img,
                  :identity_card_front_img
                  )
  end
  alias :create_params :personal_authentication_params
  alias :update_params :personal_authentication_params

  def valid_create_params
    @errors = []
    code15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/ # 15位身份证号
    code18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/ # 18位身份证号
    identity_card_match = (personal_authentication_params[:identity_card_code] =~ code15 || personal_authentication_params[:identity_card_code] =~ code18)
    hash = {
      '验证码错误或已过期。': MobileAuthCode.auth_code(personal_authentication_params[:mobile], personal_authentication_params[:mobile_auth_code]),
      '手持身份证照片不能为空。': params[:personal_authentication][:face_with_identity_card_img],
      '身份证照片不能为空。': params[:personal_authentication][:identity_card_front_img],
      '姓名不能为空。': personal_authentication_params[:name],
      '身份证号码错误。': identity_card_match,
      '地址不能为空。': personal_authentication_params[:address],
      '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
    }
    hash.each do |k, v|
      @errors << k if v.blank?
    end
  end

  def valid_update_params
    @errors = []
    code15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/ # 15位身份证号
    code18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/ # 18位身份证号
    identity_card_match = (personal_authentication_params[:identity_card_code] =~ code15 || personal_authentication_params[:identity_card_code] =~ code18)
    hash = {
      '验证码错误或已过期。': MobileAuthCode.auth_code(personal_authentication_params[:mobile], personal_authentication_params[:mobile_auth_code]),
      '姓名不能为空。': personal_authentication_params[:name],
      '身份证号码错误。': identity_card_match,
      '地址不能为空。': personal_authentication_params[:address],
      '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
    }
    hash.each do |k, v|
      @errors << k if v.blank?
    end
  end
end
