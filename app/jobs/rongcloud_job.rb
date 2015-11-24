class RongcloudJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.find_or_create_rongcloud_token
  end
end
