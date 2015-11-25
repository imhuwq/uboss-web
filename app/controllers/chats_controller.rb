class ChatsController < ApplicationController

  def show
    render layout: 'mobile'
  end

  def token
    render json: { token: current_user.find_or_create_rongcloud_token }
  end

  def user_info
    @user = User.find(params[:target_id])
    render json: { id: @user.id, nickname: @user.identify, avatar: @user.avatar.url }
  end

end
