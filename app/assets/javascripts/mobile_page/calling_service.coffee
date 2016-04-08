$ ->
  $('.calling-service-btn').on "click", (e) ->
    console.log('呼叫服务')
    url = $(this).data('url')
    $.ajax
      url: url
      type: 'PATCH'
      success: (res) ->
        if res['status'] == "ok"
          console.log('呼叫成功')
      error: (data, status, e) ->
        alert("操作错误, 请刷新后再尝试")
        #location.reload()
