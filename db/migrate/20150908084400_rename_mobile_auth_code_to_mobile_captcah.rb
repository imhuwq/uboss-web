class RenameMobileAuthCodeToMobileCaptcah < ActiveRecord::Migration
  def up
    rename_table :mobile_auth_codes, :mobile_captchas
  end

  def down
    rename_table :mobile_captchas, :mobile_auth_codes
  end
end
