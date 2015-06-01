class Admin::MainController < Admin::BaseController
  before_filter :signed_in_user
  def index
  end
end