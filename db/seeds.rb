
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
  admin: true
)
u1.user_roles = [super_role,agent_role,seller_role]
u1.save

u2 = User.create(
  login: '13800000001',
  mobile: '13800000001',
  password: '111111',
  nickname: "agent1",
  admin: true
)
u2.user_roles = [agent_role,seller_role]
u2.save

u3 = User.create(
  login: '13800000002',
  mobile: '13800000002',
  password: '111111',
  nickname: "seller1",
  agent_id: u2.id,
  admin: true
)
u3.user_roles = [seller_role]
u3.save
