class Admin::EnterpriseAuthenticationsController < AdminController
  include Certifications

  def klass
    EnterpriseAuthentication
  end

  private

  def resource_params
    params.require(:enterprise_authentication).permit(:mobile, :address, :enterprise_name,
                    :business_license_img, :legal_person_identity_card_front_img,
                    :legal_person_identity_card_end_img,
                    :mobile_auth_code, :province_code, :city_code, :district_code)
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
