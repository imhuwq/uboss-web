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
      render_success('取消关注成功')
    else
      render_error :validation_failed, '取消关注失败'
    end
  end

  def follow
    @user.followings << User.find(params[:user_id])
    if @user.save
      render_success('关注成功')
    else
      render_error :validation_failed, '关注失败'
    end
  end

  private
  def find_user
    @user = User.find_by_name(params[:name])
  end

end
