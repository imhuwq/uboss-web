class CreatePersonalAuthentication < ActiveRecord::Migration
  def change
    create_table :personal_authentications do |t|
      t.belongs_to :user
      t.integer :status , default: 0
      t.string  :name
      t.string  :identity_card_code
      t.string  :face_with_identity_card_img
      t.string  :identity_card_front_img
      t.string  :address
      t.string  :mobile
    end
  end
end
