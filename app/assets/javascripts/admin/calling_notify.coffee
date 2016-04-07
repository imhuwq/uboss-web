  $(document).on 'ajax:beforeSend', '#calling_notifies .change-status-btn', (xhr, settings) ->
    return confirm("确定#{$(this).data('text')}?")

  $(document).on 'ajax:success', "#calling_notifies .change-status-btn", (e, data) ->
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .calling_notify').length > 0
      $(this).closest('.calling_notify').html(html.find('tbody .calling_notify').html())

  $(document).on 'ajax:error', "#calling_notifies .change-status-btn", ->
    alert('操作失败')
