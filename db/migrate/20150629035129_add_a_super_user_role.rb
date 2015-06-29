class AddASuperUserRole < ActiveRecord::Migration
  def up
    UserRole.create(name: 'super_admin', display_name: '超级管理员')
    UserRole.create(name: 'seller', display_name: '商户')
  end

  def down

  end
end
