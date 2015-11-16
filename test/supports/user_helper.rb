module UserHelper

  def create_or_find_official_account
    User.official_account || create(:user, login: User::OFFICIAL_ACCOUNT_LOGIN)
  end

end

ActionController::TestCase.send(:include, UserHelper)
ActiveSupport::TestCase.send(:include, UserHelper)
