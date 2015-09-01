class Api::V1::UsersController < ApiBaseController

  def index
    @users = User.limit(10)
  end

end
