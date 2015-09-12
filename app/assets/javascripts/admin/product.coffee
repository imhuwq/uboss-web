$ ->
  $(document).on 'ajax:success', '#products .switch-p-hot-btn', (e, data) ->
    if data.hot
      $(this).removeClass('fa-heart-o').addClass('fa-heart')
    else
      $(this).removeClass('fa-heart').addClass('fa-heart-o')

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

  $(document).on 'ajax:error', "#products .change-status-btn, #products .switch-p-hot-btn", ->
    alert('操作失败')
