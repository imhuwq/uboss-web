class Api::V1::ChatsController < ApiBaseController

  def token
    render json: { token: current_user.find_or_create_rongcloud_token }
  end

end
