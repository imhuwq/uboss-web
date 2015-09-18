class FillUsersAuthenticationToken < ActiveRecord::Migration
  def up
    say_with_time "Filling users authentication_token" do
      User.where(authentication_token: nil).each do |user|
        user.__send__(:ensure_authentication_token)
        user.update_column(:authentication_token, user.authentication_token)
      end
    end
  end
end
