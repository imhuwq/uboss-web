class CreateCertifications < ActiveRecord::Migration
  def change
    create_table :certifications do |t|
      t.belongs_to  :user
      t.integer     :status           # 状态
      t.string      :name             # 个人名称
      t.string      :enterprise_name  # 企业名称
      t.string      :id_num           # 身份证号
      t.string      :address          # 地址
      t.string      :mobile           # 手机号
      t.string      :attachment_1     # 图片1
      t.string      :attachment_2     # 图片2
      t.string      :attachment_3     # 图片3
      t.string      :type

      t.timestamps null: false
    end

    add_index :certifications, :user_id
end