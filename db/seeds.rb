
p "Create 3 necessary user_role"
super_role = UserRole.find_or_create_by(name: 'super_admin', display_name: '超级管理员')
agent_role = UserRole.find_or_create_by(name: 'agent', display_name: '创客')
seller_role = UserRole.find_or_create_by(name: 'seller', display_name: '商户')

p "Create UBOSS official account"
u1 = User.create(
  login: '13800000000',
  mobile: '13800000000',
  password: '111111',
  nickname: "UBOSS",
  store_name: "UBOSS官方",
  authenticated: 'yes',
  admin: true
)
u1.user_roles = [super_role,agent_role,seller_role]
u1.save

ChinaCity.provinces.each do |name, code|
  province = Region.find_or_create_by(name: name, numcode: code)

  ChinaCity.list(code).each do |city_name, city_code|
    city = Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: province.id )

    ChinaCity.list(city_code).each do |area_name, area_code|
      Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: city.id )
    end
  end
end

Region.find_or_create_by(name: '其他')

