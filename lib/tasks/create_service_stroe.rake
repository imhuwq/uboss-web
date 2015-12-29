namespace :user_db do
  desc 'init service store'
  task init_service_store: :environment do
    puts '开始创建service store for created users'

    User.all.each do |user|
      if user.service_store.blank?
        user.build_service_store
        puts user.save(validate: false)
      end
    end

    puts '创建团购店铺完毕!'
  end
end
