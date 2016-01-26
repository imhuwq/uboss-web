json.extract! @user,
  :id, :email, :mobile, :authentication_token, :nickname,
  :need_reset_password, :avatar_url, :authenticated, :agent_code,
  :good_evaluation, :best_evaluation, :better_evaluation, :worst_evaluation, :bad_evaluation
json.login @user.login.to_s
json.roles do
  json.array! @user.user_roles do |user_role|
    json.extract! user_role, :name, :display_name
  end
end
