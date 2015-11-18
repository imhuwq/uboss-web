class ChatsController < ApplicationController

  def show
    render layout: 'mobile'
  end

  def token
    if current_user.rongcloud_token.present?
      render json: { token: current_user.rongcloud_token }
    else
      user = Rongcloud::Service::User.new
      user.user_id = current_user.id
      user.name = current_user.identify
      user.portrait_uri = current_user.avatar.url(:thumb)
      user.get_token
      current_user.update_columns(rongcloud_token: user.token)
      render json: { token: user.token }
    end
  end

end
