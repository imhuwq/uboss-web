namespace :advertisement_db do
  desc 'move old advertisement'
  task move_old_advertisement: :environment do
    puts '开始迁移广告'

    Advertisement.delegate :remote_avatar_url=, to: :asset_img

    UserInfo.all.each do |obj|
      p "Migrating: user_id #{obj.user_id}"
      if obj.store_banner_one_identifier
        Advertisement.create(
          user_id: obj.user_id,
          product_id: obj.recommend_resource_one_id,
          avatar: obj.store_banner_one_identifier,
          platform_advertisement: false
        )
      end
      if obj.store_banner_two_identifier
        Advertisement.create(
          user_id: obj.user_id,
          product_id: obj.recommend_resource_two_id,
          avatar: obj.store_banner_two_identifier,
          platform_advertisement: false)
      end
      if obj.store_banner_thr_identifier
        Advertisement.create(
          user_id: obj.user_id,
          product_id: obj.recommend_resource_thr_id,
          avatar: obj.store_banner_thr_identifier,
          platform_advertisement: false)
      end
      p "Migrating: user_id #{obj.user_id} DONE"
    end

    puts '迁移广告成功!'
  end
end
