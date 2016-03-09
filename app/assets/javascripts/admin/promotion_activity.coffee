$ ->
  $(document).on 'ajax:beforeSend', '#promotion_activities .change-status-btn', (xhr, settings) ->
    return confirm("确定#{$(this).text()}?")

  $(document).on 'ajax:success', "#promotion_activities .change-status-btn", (e, data) ->
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container .alert').remove()
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .promotion_activity').length > 0
      $(this).closest('.promotion_activity').html(html.find('tbody .promotion_activity').html())
    else
      $(this).closest('.promotion_activity').remove()

  $(document).on 'ajax:error', "#promotion_activities .change-status-btn", ->
    alert('操作失败')

