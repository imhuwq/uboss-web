class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user

  def followers
    user_ids = AttentionAssociation.where(following_id: @user.id).collect(&:user_id)
    @users = User.where(id: user_ids)
  end

  def following
    @users = @user.followings
  end

  def unfollow
    following = User.find(params[:user_id])
    if @user.followings.destroy(following)
      render_success('取消关注成功')
    else
      render_fail('取消关注失败')
    end
  end

  def follow
    @user.followings << User.find(params[:user_id])
    if @user.save
      render_success('关注成功')
    else
      render_fail('关注失败')
    end
  end

  private
  def find_user
    @user = User.find_by_login(params[:login])
  end
end
