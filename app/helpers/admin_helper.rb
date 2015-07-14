module AdminHelper

  def detail_pannel(name, options ={}, &block)
    pannel_content = capture(&block)
    name.is_a?(Class) ? name.model_name.human : name
    options[:type] ||= 'info'

    dropdown_list_string = <<-HTML
      <div class="panel panel-#{options[:type]}">
        <div class="panel-heading">
          <h3 class="panel-title">#{name}</h3>
        </div>
        <div class="panel-body">
          #{pannel_content}
        </div>

      </div>
    HTML
    dropdown_list_string.html_safe
  end

end
