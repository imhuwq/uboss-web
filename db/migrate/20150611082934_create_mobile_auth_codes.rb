class CreateMobileAuthCodes < ActiveRecord::Migration
  def change
    create_table :mobile_auth_codes do |t|
      t.string :code
      t.datetime :expire_at
      t.string :mobile
      t.timestamps
    end
  end
end
