class UsersController < ApplicationController
  #before_action :authenticate_user!
  before_action :find_user

  def followers
    @users = Attention.where(follower_id: @user.id)
  end

  def following
    @users = Attention.where(following_id: @user.id)
  end

  def unfollow
    @user = Attention.where(following_id: @user.id, follower_id: params[:user_id]).first
    if @user.destroy
      render_success('取消关注成功')
    else
      render_fail('取消关注失败')
    end
  end

  def follow
    @user = Attention.new(following_id: @user.id, follower_id: params[:user_id])
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
