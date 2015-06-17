module LoginHelper
  include Devise::TestHelpers

  def login_in user = nil
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = user || current_user
    # for future API feature
    @request.env["HTTP_ACCESSTOKEN"] = user.accesstoken
    user.tap { |u| sign_in u }
  end

  def current_user
    @current_user ||= create(:user)
  end
end

ActionController::TestCase.send(:include, LoginHelper)
