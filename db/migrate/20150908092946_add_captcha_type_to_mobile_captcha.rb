class AddCaptchaTypeToMobileCaptcha < ActiveRecord::Migration
  def change
    add_column :mobile_captchas, :captcha_type, :string
  end
end
