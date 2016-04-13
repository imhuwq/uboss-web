module OperationLoggable
  extend ActiveSupport::Concern

  included do
    after_action :log_admin_operation
  end

  def log_admin_operation
    return if ["GET", "HEAD"].include?(request.method)

    id                    = "id=#{params[:id].nil? ? '-' : params[:id]}"
    user                  = "User#{original_current_user.nil? ? '-' : original_current_user.id}"
    status                = "status=#{response.status}"
    request_method        = "#{request.method}"
    controller_and_action = "Admin::#{controller_name.camelcase}##{action_name.camelcase}"

    log_content = [user, request_method, controller_and_action, id, status].join(" ")
    OperationLogger.info log_content
  end
end
