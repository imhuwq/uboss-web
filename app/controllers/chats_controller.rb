class ChatsController < ApplicationController

  def show
    render layout: 'mobile'
  end

  def token
    render json: { token: current_user.find_or_create_rongcloud_token }
  end

end
