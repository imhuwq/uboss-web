module ApplicationHelper

  def alert_box(message, opts = {})
    alert_type = opts.delete(:type) || 'alert-info'
    content_tag :div, message, class: "alert #{alert_type}", role: 'alert'
  end

end
