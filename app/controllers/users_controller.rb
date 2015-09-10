class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: [:followers, :following]

  def followers
    @users = Attention.where(follower_id: @user.id)
  end

  def following
    @users = Attention.where(following_id: @user.id)
  end

  def unfollow
    @user = Attention.where(following_id: current_user.id, follower_id: params[:user_id])
    @user.destroy
  end

  def follow
    @user = Attention.new(following_id: current_user.id, follower_id: params[:user_id])
  end

  private
  def find_user
    @user = User.find_by_login(params[:login])
  end
end
