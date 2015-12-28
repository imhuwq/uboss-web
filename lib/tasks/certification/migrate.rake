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
        status:   personal.status,
        name:     personal.name,
        address:  personal.address,
        mobile:   personal.mobile,
        id_num:   personal.identity_card_code,
        face_with_identity_card_img: personal.face_with_identity_card_img
      }
      Certification.create(attrs)
    end

    TmpEnterpriseAuthentication.find_each do |enterprise|
      attrs = {
        type:                 "EnterpriseAuthentication",
        status:               enterprise.status,
        enterprise_name:      enterprise.enterprise_name,
        address:              enterprise.address,
        mobile:               enterprise.mobile,
        id_num:               enterprise.identity_card_code,
        business_license_img: File.open(enterprise.business_license_img.path),
        legal_person_identity_card_front_img: File.open(enterprise.legal_person_identity_card_front_img.path),
        legal_person_identity_card_end_img: File.open(enterprise.legal_person_identity_card_end_img.path),
      }
      Certification.create(attrs)
    end
  end
end