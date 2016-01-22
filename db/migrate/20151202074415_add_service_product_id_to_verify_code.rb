class AddServiceProductIdToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :service_product_id, :integer
  end
end
