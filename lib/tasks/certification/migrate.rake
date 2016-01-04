namespace :certification do
  desc "迁移个人认证及企业认证数据"
  task :migrate => :environment  do

    class TmpPersonalAuthentication < ActiveRecord::Base
      self.table_name = 'personal_authentications'
      mount_uploader :face_with_identity_card_img, ImageUploader
      mount_uploader :identity_card_front_img, ImageUploader
      enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }
    end

    class TmpEnterpriseAuthentication < ActiveRecord::Base
      self.table_name = 'enterprise_authentications'
      mount_uploader :business_license_img, ImageUploader
      mount_uploader :legal_person_identity_card_front_img, ImageUploader
      mount_uploader :legal_person_identity_card_end_img, ImageUploader
      enum status: { posted: 0, review: 1, pass: 2, no_pass: 3 }
    end

    TmpPersonalAuthentication.find_each do |personal|
      attrs = {
        type:     "PersonalAuthentication",
        user_id:  personal.user_id,
        status:   personal.status,
        name:     personal.name,
        address:  personal.address,
        mobile:   personal.mobile,
        id_num:   personal.identity_card_code,
        created_at: personal.created_at,
        updated_at: personal.updated_at,
        attachment_2: personal.face_with_identity_card_img_identifier,
        attachment_3: personal.identity_card_front_img_identifier
      }
      Certification.new(attrs).save(validate: false)
    end

    TmpEnterpriseAuthentication.find_each do |enterprise|
      attrs = {
        type:                 "EnterpriseAuthentication",
        user_id:              enterprise.user_id,
        status:               enterprise.status,
        enterprise_name:      enterprise.enterprise_name,
        address:              enterprise.address,
        mobile:               enterprise.mobile,
        # id_num:               enterprise.identity_card_code,
        attachment_1: enterprise.business_license_img_identifier,
        attachment_2: enterprise.legal_person_identity_card_front_img_identifier,
        attachment_3: enterprise.legal_person_identity_card_end_img_identifier,
        created_at: enterprise.created_at,
        updated_at: enterprise.updated_at,
      }
      Certification.new(attrs).save(validate: false)
    end

    ChinaCity.provinces.each do |province_name, province_code|
      ChinaCity.list(province_code).each do |city_name, city_code|
        certification = Certification.ransack(address_cont: city_name.gsub(/市/,'')).result.first
        if certification
          certification.update(province_code: province_code, city_code: city_code)
          print '.'
        end
      end
    end
  end
end
