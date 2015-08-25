$ ->
  $(document).on 'ajax:beforeSend', '#products .change-status-btn', (xhr, settings) ->
    return confirm("确定#{$(this).text()}?")

  $(document).on 'ajax:success', "#products .change-status-btn", (e, data) ->
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .product').length > 0
      $(this).closest('.product').html(html.find('tbody .product').html())
    else
      $(this).closest('.product').remove()

  $(document).on 'ajax:error', "#products .change-status-btn", ->
    alert('操作失败')
