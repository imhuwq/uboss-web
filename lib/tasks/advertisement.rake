namespace :advertisement_db do
  desc 'move old advertisement'
  task move_old_advertisement: :environment do
    puts '开始迁移广告'
 	UserInfo.all.each do |obj|
      if obj.store_banner_one_identifier && obj.recommend_resource_one_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_one_id, avatar: obj.store_banner_one.url.split('/')[-1], platform_advertisement: false)
      end
      if obj.store_banner_two_identifier && obj.recommend_resource_two_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_two_id, avatar: obj.store_banner_two.url.split('/')[-1], platform_advertisement: false)
      end
      if obj.store_banner_thr_identifier && obj.recommend_resource_thr_id
        Advertisement.create(user_id: obj.user_id, product_id: obj.recommend_resource_thr_id, avatar: obj.store_banner_thr.url.split('/')[-1], platform_advertisement: false)
      end
    end

    puts '迁移广告成功!'
  end
end
