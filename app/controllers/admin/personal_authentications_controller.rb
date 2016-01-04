class Admin::PersonalAuthenticationsController < AdminController

  #load_and_authorize_resource

  include Certifications

  def klass
    PersonalAuthentication
  end

  private

  def resource_params
    params.require(:personal_authentication).permit(:mobile, :address, :name,
                  :identity_card_code, :mobile_auth_code, :face_with_identity_card_img,
                  :identity_card_front_img, :province_code, :city_code, :district_code
                  )
  end
  alias :create_params :resource_params
  alias :update_params :resource_params

  # FIXME 将model的数据校验移到model
  def valid_create_params
    @errors = []
    code15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/ # 15位身份证号
    code18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/ # 18位身份证号
    identity_card_match = (resource_params[:identity_card_code] =~ code15 || resource_params[:identity_card_code] =~ code18)
    hash = {
      '验证码错误或已过期。': MobileCaptcha.auth_code(resource_params[:mobile], resource_params[:mobile_auth_code]),
      '手持身份证照片不能为空。': params[:personal_authentication][:face_with_identity_card_img],
      '身份证照片不能为空。': params[:personal_authentication][:identity_card_front_img],
      '姓名不能为空。': resource_params[:name],
      '身份证号码错误。': identity_card_match,
      '地址不能为空。': resource_params[:address],
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
    identity_card_match = (resource_params[:identity_card_code] =~ code15 || resource_params[:identity_card_code] =~ code18)
    hash = {
      '验证码错误或已过期。': MobileCaptcha.auth_code(resource_params[:mobile], resource_params[:mobile_auth_code]),
      '姓名不能为空。': resource_params[:name],
      '身份证号码错误。': identity_card_match,
      '地址不能为空。': resource_params[:address],
      '您不能操作这个用户。': current_user.id == (params[:user_id].to_i || nil)
    }
    hash.each do |k, v|
      @errors << k if v.blank?
    end
  end
end
