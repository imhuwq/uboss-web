class AddSenderIdToMobileCaptchas < ActiveRecord::Migration
  def change
    add_column :mobile_captchas, :sender_id, :integer
  end
end
