module Certifications
  extend ActiveSupport::Concern

  included do

    def klass
      Certification
    end

    def index
      authorize! :read, klass
      @certifications = append_default_filter klass, order_column: :updated_at, order_type: 'DESC'
    end

    def new
      if klass.find_by(user_id: current_user).present?
        flash[:alert] = '您的验证信息已经提交，请检查。'
        redirect_to action: :show
      end
      @certification = klass.new
      authorize! :new, klass
    end

    def show
      if can?(:manage, klass)
        @certification = klass.find_by(user_id:( params[:user_id] || current_user))
      else
        @certification = klass.find_by(user_id: current_user)
      end
      unless @certification.present?
        flash[:notice] = '您还没有认证'
        redirect_to action: :new
      else
        authorize! :read, @certification
      end
    end

    def edit
      @certification = klass.find_by(user_id: current_user)
      if !@certification.present?
        redirect_to action: :new
      elsif [:review, :pass].include?(@certification.status.to_sym)
        flash[:alert] = '当前状态不允许修改。'
        redirect_to action: :show
      else
        authorize! :edit, @certification
      end
    end

    def create
      valid_create_params
      @certification = klass.new(resource_params)
      @certification.user_id = current_user.id
      authorize! :create, @certification
      if @errors.present?
        flash[:error] = @errors.join("\n")
        render 'new'
        return
      else
        if @certification.save
          MobileCaptcha.find_by(code: resource_params[:mobile_auth_code]).try(:destroy)
          flash[:success] = '保存成功'
          redirect_to action: :show
        else
          flash[:error] = "保存失败：#{@certification.errors.full_messages.join('<br/>')}"
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
        @certification = klass.find_by!(user_id: current_user)
        authorize! :update, @certification
        hash = resource_params.merge({status: 'posted'})
        if @certification.update(hash)
          MobileCaptcha.find_by(code: resource_params[:mobile_auth_code]).try(:destroy)
          flash[:success] = '保存成功'
          redirect_to action: :show
        else
          flash[:error] = "保存失败：#{@certification.errors.full_messages.join('<br/>')}"
          redirect_to action: :edit
        end
      end
    end

    private

    def resource_params
      {}
    end

    def valid_create_params
      @errors = []
      hash = {
        '验证码错误或已过期。': MobileCaptcha.auth_code(resource_params[:mobile], resource_params[:mobile_auth_code]),
        '营业执照不能为空。': params[:enterprise_authentication][:business_license_img],
        '身份证照片正面不能为空。': params[:enterprise_authentication][:legal_person_identity_card_front_img],
        '身份证照片反面不能为空。': params[:enterprise_authentication][:legal_person_identity_card_end_img],
        '公司名不能为空。': resource_params[:enterprise_name],
        '地址不能为空。': resource_params[:address],
        '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
      }
      hash.each do |k, v|
        @errors << k unless v.present?
      end
    end

    def valid_update_params
      @errors = []
      hash = {
        '验证码错误或已过期。': MobileCaptcha.auth_code(resource_params[:mobile], resource_params[:mobile_auth_code]),
        '公司名不能为空。': resource_params[:enterprise_name],
        '地址不能为空。': resource_params[:address],
        '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
      }
      hash.each do |k, v|
        @errors << k unless v.present?
      end
    end
  end
end
