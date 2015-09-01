class ApiBaseController < ActionController::API

  # modules we may need outside ActionController::API
  include AbstractController::Translation
  include ActionController::ImplicitRender

  before_action :force_request_format
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!

  if !Rails.env.development?
    rescue_from CanCan::AccessDenied do |exception|
      render_error :forbidden, exception.message, 403
    end
    rescue_from ActionController::ParameterMissing do |exception|
      render_error :wrong_params, exception.message
    end
  end

  protected

  def render_error(errid, error_message = nil, status_code = 422)
    render json: { errid: errid, errmsg: error_message }, status: status_code
  end

  def authentication_token
    request.headers["User-Token"] || params[:accesstoken]
  end

  def authentication_login
    request.headers["User-Login"] || params[:login]
  end

  def authenticate_user_from_token!
    user = authentication_login && User.find_by(login: authentication_login)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, authentication_token)
      # disable tracking user each times cos we enable it
      env['devise.skip_trackable'] = true
      sign_in user, store: false
    end
  end

  def force_request_format
    request.format = 'json'
  end

end
