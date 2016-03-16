namespace :category do
  desc 'add store to category'
  task add_store_to_category: :environment do
    puts '开始迁移category数据'
    Category.all.each do |category|
      category.store_id = category.user.ordinary_store.id
      category.store_type = category.user.ordinary_store.class.name
      category.save
    end
  end
end

