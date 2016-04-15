$ ->
  $('.calling-service-btn').on "click", (e) ->
    e.preventDefault()
    if(!$(this).hasClass('disabled'))
      url = $(this).data('url')
      $this = $(this)
      $this.addClass('disabled')
      $.ajax
        url: url
        type: 'PATCH'
        success: (res) ->
          if res.status == "ok"
            if res.type == "checkout"
              location.href += '/share'
            else
              $this.closest('.calling-notify-box').append('<p class="like-color text-cut"><small>商家正在准备你所需的服务，稍等就来…</small></p>')
              time_conut = 10
              count_down = () ->
                time_conut -= 1
                if(time_conut >= 0)
                  $this.find('.time_count').text('('+time_conut+'s)')
                  setTimeout () ->
                    count_down()
                  , 1000
                else
                  $this.find('.time_count').text('')
                  $this.removeClass('disabled')
                  $this.closest('.calling-notify-box').find('p.like-color').remove()
              count_down()
          if res.status == "failure"
            flashPopContent('<div class="pop-text gray">呼叫错误, 请刷新后再尝试</div>')
        error: (data, status, e) ->
          $this.removeClass('disabled')
          flashPopContent('<div class="pop-text gray">操作错误, 请刷新后再尝试</div>')
          location.reload()


  $('.calling-notify-unservice').on "click", (e)->
    e.preventDefault()
    id = $(this).data('id')
    $.ajax
      url: "/account/calling_notifies/#{id}/change_status"
      type: 'PATCH'
      success: (res) ->
        if res.status == 'ok'
          if res.checkout == true
            $(".calling-notify-box[data-number=\"#{res.number}\"]").remove()
            flashPopContent("<div class=\"pop-text gray\">#{res.msg}</div>")
          else
            $(".calling-notify-unservice[data-id=\"#{res.id}\"]")
              .removeClass('calling-notify-unservice')
              .addClass('btn-gray')
              .html('已服务')
            flashPopContent("<div class=\"pop-text gray\">#{res.msg}</div>")
        if res.status == 'failure'
          flashPopContent("<div class=\"pop-text gray\">#{res.error_msg}</div>")
      error: (data, status, e) ->
        flashPopContent('<div class="pop-text gray">操作错误, 请刷新后再尝试</div>')
        location.reload()


  $('.table-number-list .box-w25').on 'click', (e)->
    e.preventDefault()
    if !$(this).hasClass('selected')
      $('.table-number-list .box-w25').removeClass('active')
      $(this).addClass('active')

  $('.calling-order-service button').on 'click', (e)->
    e.preventDefault()
    if $('.box-w25.active').length == 0
      flashPopContent('<div class="pop-text gray">请选择一个号桌</div>')
    else
      number = $('.box-w25.active span').html()
      url    = $(this).data('url')
      $.ajax
        url: url
        type: 'POST'
        data: {number: number}
        success: (res)->
          if res.status == "ok"
            location.href = res.redirect_url
          if res.status == "failure"
            flashPopContent("<div class=\"pop-text gray\">#{res.error_msg}</div>")
        error: (data, status, e)->
          flashPopContent('<div class="pop-text gray">操作错误, 请刷新后再尝试</div>')
          location.reload()
