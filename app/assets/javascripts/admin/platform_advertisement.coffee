  $(document).on 'ajax:beforeSend', '#platform_advertisements .change-status-btn', (xhr, settings) ->
    return confirm("确定#{$(this).text()}?")

  $(document).on 'ajax:success', "#platform_advertisements .change-status-btn", (e, data) ->
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .platform_advertisement').length > 0
      $(this).closest('.platform_advertisement').html(html.find('tbody .platform_advertisement').html())

  $(document).on 'ajax:error', "#platform_advertisements .change-status-btn", ->
    alert('操作失败')