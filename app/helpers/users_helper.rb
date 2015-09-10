module UsersHelper
  def current_user_is_follow_one?(user)
    Attention.where(follower_id: user.id, following_id: current_user.id).first
  end
end
