namespace :user_db do
  desc 'add agent role to all user'
  task add_agent_role: :environment do
    puts '开始添加用户角色'

    User.where(id: User.pluck(:id) - User.agent.pluck(:id)).each do |user|
      if !user.is_agent?
        user.admin = true
        user.user_roles << UserRole.agent
        user.save
      end
    end

    puts '用户角色添加成功!'
  end
end
