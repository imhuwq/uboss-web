$(document).on 'ajax:beforeSend', '#calling_notifies .change-status-btn', (xhr, settings) ->
  if $(this).data('service-name') == "结帐"
    return confirm("点击去结帐服务后将自动下桌并清空所有服务通知，确定结帐？")

$(document).on 'ajax:success', "#calling_notifies .change-status-btn", (e, data) ->
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
  if $('#realtime-modal').hasClass('notice')
    $('#realtime-modal .modal-title').html('服务通知')
    $('#realtime-modal').modal()

  instructionPNotice = ->
    instruction = new PNotify({
      title: '服务说明',
      text: '1.还未提供的服务，点击<a class="btn btn-mid">去服务</a>，让消费者知道所需要的服务即将到来；<br /><br />2.已提供的服务，点击<a class="btn btn-mid white-btn btn-border">已服务</a>，不让消费者收到服务消息的骚扰.',
      type: 'info',
      icon: false,
      animate_speed: 'fast',
      buttons: {
        closer: true,
        sticker: false,
        labels: {close: "关闭"}
      }
    })
    instruction.get().on 'click', ->
      instruction.remove()
    $('.operating-instructions').on 'mouseout', ->
      instruction.remove()

  $('.operating-instructions').on 'mouseover', ->
    instructionPNotice()


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
