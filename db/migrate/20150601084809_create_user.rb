class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email
      t.string   :name
      t.text     :note
      t.integer  :tp,                                      :default => 1
      t.string   :status,                                  :default => "stop"
      t.string   :logo
      t.string   :salt
      t.string   :crypted_password
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :gender,                                  :default => "M"
      t.string   :phone,                                   :default => ""
      t.string   :weixin_code
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
