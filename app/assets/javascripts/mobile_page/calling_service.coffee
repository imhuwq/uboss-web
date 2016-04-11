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
            $this.text('呼叫'+10+'s')
            calling_count($this,10)
            setTimeout  ->
              $this.removeClass('disabled')
            ,10000
          if res['status'] == "failure"
            console.log('呼叫错误，请刷新再尝试')
        error: (data, status, e) ->
          alert("操作错误, 请刷新后再尝试")
          location.reload()
