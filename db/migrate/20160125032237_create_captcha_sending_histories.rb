class CreateCaptchaSendingHistories < ActiveRecord::Migration
  def change
    create_table :captcha_sending_histories do |t|
      t.string :code
      t.datetime :code_sent_at
      t.datetime :code_expired_at
      t.integer :sender_id, index: true
      t.integer :receiver_id, index: true
      t.string :receiver_mobile
      t.integer :invite_type
      t.integer :invite_status

      t.timestamps null: false
    end
  end
end
