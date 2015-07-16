namespace :assets do
  task :publish_my_holy_shinning_precompiled_miraculous_assets_to_the_almighty_upyun do
    RailsAssetsForUpyun.publish(
      Rails.application.secrets.upyun['assets_bucket'],
      Rails.application.secrets.upyun['username'],
      Rails.application.secrets.upyun['password']
    )
  end
end
