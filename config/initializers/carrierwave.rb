module CarrierWave::Storage
  class UpYun
    class File
      def delete
        true
      end
    end
  end
end

if !Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :upyun

    config.upyun_username = Rails.application.secrets.upyun['username']
    config.upyun_password = Rails.application.secrets.upyun['password']
    config.upyun_bucket = Rails.application.secrets.upyun['bucket']
    config.upyun_bucket_host = Rails.application.secrets.upyun['bucket_host']
  end
end
