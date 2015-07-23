module ApplicationHelper

  def alert_box(message, opts = {})
    alert_type = opts.delete(:type) || 'alert-info'
    content_tag :div, message, class: "alert #{alert_type}", role: 'alert', data: {dismiss: 'alert'} do
      [
        content_tag(:button, class: 'close') do
          content_tag(:span, '×')
        end,
        message
      ].join.html_safe
    end
  end

  def nav_group(name, &block)
    list = capture(&block)
    text = t(name, scope: "nav_groups", default: name.to_s.humanize)
    active_status = /[^_\-a-aA-Z]active/.match(list) ? "active" : ""

    dropdown_list_string = <<-HTML
    <li class="dropdown #{active_status}">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">#{text}<span class="caret"></span></a>
      <ul class="dropdown-menu" role="menu">#{list}</ul>
    </li>
    HTML
    dropdown_list_string.html_safe
  end

  def li_link name, path, opts = {}
    i18n_key = opts.delete(:i18n_key)
    active_class = active?(opts.delete(:another_active_name) || name)
    content_tag :li, { class: active_class.to_s }.merge(opts) do
      content_tag :a, I18n.t("li_link.#{i18n_key || name}"), href: path
    end
  end

  def can_li_link operate, resource, path, opt = {}
    link_name = opt[:link_name]
    link_name ||= resource.is_a?(Class) ? resource.name.tableize : resource
    li_link(link_name, path, opt) if can?(operate, resource)
  end

  def active? chapter
    if controller_name == chapter.to_s
      'active'
    end
  end

  def sharing_meta_tags(meta_tags)
    meta_tags.collect do |key, value|
      content_tag :meta, '', name: key, content: value
    end.join.html_safe
  end

  def displayable_class(boolean_value)
    boolean_value ? '' : 'hidden'
  end

  def abled_class(boolean_value)
    boolean_value ? '' : 'disabled'
  end

end
