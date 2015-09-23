$ ->

  $(document).on 'click', '.sharing-button-tsina', (e) ->
    e.preventDefault()
    UBoss.luffy.shareToWeibo()

  $(document).on 'click', '.sharing-button-tqq', (e) ->
    e.preventDefault()
    UBoss.luffy.shareToQzone()

  $(document).on 'click', '.sharing-copycardid', (e) ->
    e.preventDefault()
    $(this).closest('.share-btns-group').find('.sharing-link').toggle()

  $(document).on 'click', '.sharing-button-wx', (e) ->
    e.preventDefault()
    if window.wx != undefined
      $(".wx-mod-pop").show()
    else
      alert('朋友圈分享只在微信浏览器可用')

  $(document).on 'click', '.req-pro-snode-btn', (e) ->
    e.preventDefault()
    _ele = $(this)
    mobile = _ele.closest('.share-content').find('input[name=mobile]').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    pid = _ele.data('pid')
    if checkNum.test(mobile)
      $.ajax
        url: _ele.attr('href')
        type: 'GET'
        data:
          mobile: mobile
          product_id: pid
      .done (data)->
        _ele.closest('.share-content').removeClass('need-snode')
        _ele.closest('.share-content').find('.sharing-link').text(data.sharing_link)
        $('meta[name=sharing_link]').attr('content', data.sharing_link)
        UBoss.luffy.resetInvokeSharing()
      .fail (xhr, textStatus) ->
        alert(
          try
            JSON.parse(xhr.responseText).message
          catch error
            '获取失败'
        )
    else
      alert("手机格式不正确")
