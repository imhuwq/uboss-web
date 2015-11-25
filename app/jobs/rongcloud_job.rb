class RongcloudJob < ActiveJob::Base
  queue_as :default

  attr_reader :user
  def perform(user)
    @user = user

    if user.rongcloud_token.blank?
      set_rongcloud_toke
    else
      refresh_rongcloud_userinfo
    end
  end

  private
  def set_rongcloud_toke
    user.find_or_create_rongcloud_token
  end

  def refresh_rongcloud_userinfo
    rong_user = Rongcloud::Service::User.new

    rong_user.user_id      = user.id
    rong_user.name         = user.identify
    rong_user.portrait_uri = user.avatar_url(:thumb)

    rong_user.refresh
  end
end
