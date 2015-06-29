# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create two necessary user_role
super_role  = UserRole.create(name: 'super_admin', display_name: '超级管理员')
seller_role = UserRole.create(name: 'seller', display_name: '商户')

# Create Admin User
User.create(
  login: '13800000000',
  mobile: '13800000000',
  password: 'password',
  user_role: super_role,
  admin: true
)

User.create(
  login: '13800000001',
  mobile: '13800000001',
  password: 'password',
  user_role: seller_role,
  admin: true
)
