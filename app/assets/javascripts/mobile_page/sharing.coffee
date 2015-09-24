$ ->

  $(document).on 'click', '.show-req-snode-modal', (e) ->
    e.preventDefault()
    _ele = $(this)
    if _ele.data('uid')
      $.ajax
        url: _ele.attr('href')
        type: 'GET'
        data:
          product_id: _ele.data('pid')
      .done (data)->
        $('.req-snode-modal .req-snode-group').hide().next().show()
        $('.req-snode-modal').show()
      .fail (xhr, textStatus) ->
        alert(
          try
            JSON.parse(xhr.responseText).message
          catch error
            '获取失败'
        )
    else
      $('.req-snode-modal').show()

  $(document).on 'click', '.pro-snode-success-btn', (e) ->
    e.preventDefault()
    $('.req-snode-modal').hide()
    $('.show-req-snode-modal').hide().next().show()
    if window.wx?
      UBoss.luffy.showWxPopTip()
    else
      UBoss.luffy.toggleSharingContent()

  $(document).on 'click', '.p-sharing-btn', (e) ->
    e.preventDefault()
    UBoss.luffy.toggleSharingContent()

  $(document).on 'click', '#close-area', (e) ->
    UBoss.luffy.toggleSharingContent()

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
    UBoss.luffy.showWxPopTip()

  $(document).on 'click', '.req-pro-snode-btn', (e) ->
    e.preventDefault()
    _ele = $(this)
    mobile = _ele.closest('.req-snode-group').find('input[name=mobile]').val()
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
        $('meta[name=sharing_link]').attr('content', data.sharing_link)
        UBoss.luffy.resetInvokeSharing()
        _ele.closest('.req-snode-group').hide().next().show()
      .fail (xhr, textStatus) ->
        alert(
          try
            JSON.parse(xhr.responseText).message
          catch error
            '获取失败'
        )
    else
      alert("手机格式不正确")
