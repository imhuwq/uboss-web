module ApplicationHelper
  ALERT_DEFAULT = { type: 'secondary', level: 'info' }

  def alert_box(message, opts = {})
    content_classes = ALERT_DEFAULT.merge(opts).map { |k,v| v}

    content_tag :div, class: "alert-box #{content_classes.join(' ')}" do
      [
        message,
        link_to('&times;'.html_safe, '#', class: 'close')
      ].join.html_safe
    end
  end
end
