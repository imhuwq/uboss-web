
p 'Create 3 necessary user_role'
super_role = UserRole.find_or_create_by(name: 'super_admin', display_name: '超级管理员')
agent_role = UserRole.find_or_create_by(name: 'agent', display_name: '创客')
seller_role = UserRole.find_or_create_by(name: 'seller', display_name: '商户')
ordinary_store_seller_role = UserRole.find_or_create_by(name: 'ordinary_store_seller', display_name: '普通商户')
service_store_seller_role = UserRole.find_or_create_by(name: 'service_store_seller', display_name: '团购商户')

p 'Create UBOSS official account'
u1 = User.create(
  login: '13800000000',
  mobile: '13800000000',
  password: '111111',
  nickname: 'UBOSS',
  authenticated: 'yes',
  admin: true
)
u1.user_roles = [super_role, agent_role, seller_role]
u1.save

u2 = User.create(
  login: '19812345678',
  mobile: '13800000000',
  password: '111111',
  nickname: 'UBOSS',
  authenticated: 'yes',
  admin: true
)

ChinaCity.provinces.each do |name, code|
  province = Region.find_or_create_by(name: name, numcode: code)

  ChinaCity.list(code).each do |city_name, city_code|
    city = Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: province.id)

    ChinaCity.list(city_code).each do |_area_name, _area_code|
      Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: city.id)
    end
  end
end
