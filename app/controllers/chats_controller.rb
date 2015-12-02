class ChatsController < ApplicationController

  before_action :authenticate_user!

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

  def check_user_online
    @user = User.find(params[:user_id])
    rong_user = Rongcloud::Service::User.new
    rong_user.user_id = @user.id
    result = rong_user.check_online
    render json: { online: result[:code] == 200 && result[:status] == '1' }
  end

end
