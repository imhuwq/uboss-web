$ ->
  $('.calling-service-btn').on "click", (e) ->
    if(!$(this).hasClass('disabled'))
      console.log('呼叫服务')
      url = $(this).data('url')
      $this = $(this)
      $.ajax
        url: url
        type: 'PATCH'
        success: (res) ->
          if res['status'] == "ok"
            console.log('呼叫成功')
            $this.addClass('disabled')
            $this.closest('.calling-notify-box').append('<p class="like-color text-cut"><small>商家正在准备你所需的服务，稍等就来…</small></p>')
            time_conut = 10
            count_down = () ->
              time_conut -= 1
              if(time_conut >= 0)
                $this.find('.time_count').text('('+time_conut+')');                
                setTimeout () ->
                  count_down()
                , 1000
              else
                $this.find('.time_count').text('')
                $this.removeClass('disabled')  
                $this.closest('.calling-notify-box').find('p.like-color').remove() 
                   
            count_down()
            
          if res['status'] == "failure"
            console.log('呼叫错误，请刷新再尝试')
        error: (data, status, e) ->
          alert("操作错误, 请刷新后再尝试")
          location.reload()
