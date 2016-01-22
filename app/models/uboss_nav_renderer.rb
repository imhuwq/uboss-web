class UbossNavRenderer < SimpleNavigation::Renderer::Base

  def render(item_container)
    if skip_if_empty? && item_container.empty?
      ''
    else
      tag = options[:ordered] ? :ol : :ul
      content = list_content(item_container)
      if content.present?
        content_tag(tag, content, item_container.dom_attributes)
      else
        ''
      end
    end
  end

  private

  def list_content(item_container)
    item_container.items.map { |item|
      li_options = item.html_options.except(:link)
      sub_navigation = ''
      if include_sub_navigation?(item)
        first_item = item.sub_navigation.items.first
        item.instance_variable_set('@url', item.sub_navigation.items.first.url) if first_item
        sub_navigation = render_sub_navigation_for(item)
      end
      li_content = tag_for(item)
      if sub_navigation.present?
        content_tag(:li, li_content, li_options)
      elsif !include_sub_navigation?(item)
        content_tag(:li, li_content, li_options)
      else
        ''
      end
    }.join
  end

end
