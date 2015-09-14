class AddIndexToMobileCaptcha < ActiveRecord::Migration
  def change
    add_index :mobile_captchas, :mobile
  end
end
