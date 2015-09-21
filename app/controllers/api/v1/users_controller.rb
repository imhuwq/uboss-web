class Api::V1::UsersController < ApiBaseController
  before_action :find_user

  def followers
    @users = @user.followers
  end

  def following
    @users = @user.followings
  end

  def unfollow
    following = User.find(params[:user_id])
    if @user.followings.destroy(following)
      head(200)
    else
      render_error :validation_failed, model_errors(@user)
    end
  end

  def follow
    @user.followings << User.find(params[:user_id])
    if @user.save
      head(200)
    else
      render_error :validation_failed, model_errors(@user)
    end
  end

  private
  def find_user
    @user = User.find_by_name(params[:name])
  end

end
