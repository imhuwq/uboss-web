require "test_helper"

class CanAccessHomeTest < Capybara::Rails::TestCase
  let(:user) { create(:user) }

  test "logined info" do
    #login_as(user, scope: :user)
    #visit root_path
    #assert_content page, "coming soon"
    #assert_content page, user.login.to_s
  end
end
