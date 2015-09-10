class Api::V1::UsersController < ApiBaseController
  before_action :find_user, only: [:followers, :following]

  def followers
    @users = Attention.where(follower_id: @user.id)
  end

  def following
    @users = Attention.where(following_id: @user.id)
  end

  def unfollow
    @user = Attention.where(following_id: current_user.id, follower_id: params[:user_id])
    if @user.destroy
      render_success("取消关注成功")
    else
      render_fail('取消关注失败', @user)
    end
  end

  def follow
    @user = Attention.new(following_id: current_user.id, follower_id: params[:user_id])
    if @user.save
      render_success("关注成功")
    else
      render_fail('关注失败', @user)
    end
  end

  private
  def find_user
    @user = User.find_by_name(params[:name])
  end

end
