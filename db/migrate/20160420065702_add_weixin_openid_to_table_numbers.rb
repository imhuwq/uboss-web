class AddWeixinOpenidToTableNumbers < ActiveRecord::Migration
  def change
    add_column :table_numbers, :weixin_openid, :string
  end
end
