class ApiBaseController < ActionController::API

  # modules we may need outside ActionController::API
  include AbstractController::Translation
  include ActionController::ImplicitRender

  before_action :force_request_format

  private

  def force_request_format
    request.format = 'json'
  end

end
