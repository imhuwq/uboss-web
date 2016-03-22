class CreateSupplierStoreInfos < ActiveRecord::Migration
  def change
    create_table :supplier_store_infos do |t|
      t.string :guess_province
      t.string :guess_city
      t.string :phone_number
      t.string :wechat_id
      t.integer :supplier_store_id, index: true

      t.timestamps null: false
    end
  end
end
