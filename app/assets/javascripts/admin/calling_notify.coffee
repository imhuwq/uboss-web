$(document).on 'ajax:beforeSend', '#calling_notifies .change-status-btn', (xhr, settings) ->
  return confirm("确定#{$(this).data('text')}?")

$(document).on 'ajax:success', "#calling_notifies .change-status-btn", (e, data) ->
  if data.type == "checkout"
    alert_html =
      """
      <div class="alert alert-success" role="alert" data-dismiss="alert">
      <button class="close"><span>×</span></button>#{data.message}</div>
      """
    $(".calling_notify[data-number=\"#{data.number}\"]").remove()
    $(".table-number[data-number=\"#{data.number}\"]").removeClass("used main-bg-color").addClass("unuse beige-bg-color")
    $('.admin-container').prepend(alert_html)
  else
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .calling_notify').length > 0
      $(this).closest('.calling_notify').html(html.find('tbody .calling_notify').html())
    else
      $(this).closest('.calling_notify').remove()

$(document).on 'ajax:error', "#calling_notifies .change-status-btn", ->
  alert('操作失败')


jQuery ($) ->
  $(document).on 'click', '.table-number.used', (e)->
    e.preventDefault()
    if confirm("确定下桌?")
      number = $(this).data('number')
      $.ajax
        url: '/admin/calling_notifies/drop_table'
        type: 'POST'
        data: {number: number}
        success: (res) ->
          if res['status'] == "ok"
            $table = $('.table-number.used[data-number="' + "#{res['number']}" + '"]')
            $table.removeClass("used main-bg-color").addClass("unuse beige-bg-color")
            $('.calling_notify[data-number="' + "#{res['number']}" + '"]').remove()
            alert('下桌成功')
          else
            alert("操作错误")
            location.reload()
        error: (data, status, e) ->
          alert("操作错误")
          location.reload()
