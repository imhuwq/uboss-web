class CreateEnterpriseAuthentication < ActiveRecord::Migration
  def change
    create_table :enterprise_authentications do |t|
      t.belongs_to :user
      t.integer :status , default: 0
      t.string  :enterprise_name
      t.string  :business_license_img
      t.string  :legal_person_identity_card_front_img
      t.string  :legal_person_identity_card_end_img
      t.string  :address
      t.string  :mobile
    end
  end
end
