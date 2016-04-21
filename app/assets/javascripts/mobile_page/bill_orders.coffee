$ ->

  requesting_bill = false
  requested_data_cache = {}
  pay_amount = Number($('#pay_amount').val())
  ssid = $('#service_store_id').val()

  invokePayment = (data) ->
    UBoss.nami.chooseWXPay
      "timestamp": data.timeStamp
      "nonceStr":  data.nonceStr
      "package":   data.package
      "signType":  data.signType
      "paySign":   data.sign
      "success":   (res) ->
        window.location.href = "/charges/" + data.order_charge_id + "/bill_complete"

  requestBill = (ssid, pay_amount) ->
    requesting_bill = true
    UBoss.chopper.showSpinner()
    $.ajax
      url: '/bill_orders'
      type: 'POST',
      data:
        pay_amount: pay_amount
        ssid: ssid
    .done (data)->
      requested_data_cache["bill-#{Number(data.pay_amount)}"] = data
      invokePayment(data)
    .fail (xhr, errorType, error)->
      alert(
        try
          JSON.parse(xhr.responseText).message
        catch error
          '付款请求失败'
      )
    .always ->
      requesting_bill = false
      UBoss.chopper.hideSpinner()

  # if pay_amount > 0
  #   requestBill(ssid, pay_amount)
  # 弹出自己的键盘
  $('#pay-number-box').on 'click', (e)->
    $('#pay-number-keyboard').removeClass('hidden')
    $('#close-keyboard').removeClass('hidden')
    $('#pay-number-box').removeClass("nofoucs")
    if( $('#pay-number-box').text() != '输入金额（元）' )
      $('#pay-number-box').addClass("active")
  $('#pay-number-keyboard .box-w33').on 'touchstart', (e)->
    $(this).addClass('touched')
  $('#pay-number-keyboard .box-w33').on 'touchend', (e)->
    $(this).removeClass('touched')
  #输入数字的判断
  $('#pay-number-keyboard .num').on 'click', (e)->
    text_number = $('#pay-number-box').text()
    if(text_number == '输入金额（元）')
      text_number = $(this).text()
      $('#pay-number-box').addClass("active")
    else
      if(text_number.indexOf("0") == 0 && text_number.length == 1)
        text_number = $(this).text()
      else if(text_number.indexOf(".") < 0)
        text_number += $(this).text()
      else if (text_number.indexOf(".")+2 >= text_number.length)
        text_number += $(this).text()
    $('#pay-number-box').text(text_number)
    $('#pay_amount').val(text_number)

  #输入点的判断
  $('#pay-number-keyboard .dot').on 'click', (e)->
    text_number = $('#pay-number-box').text()
    if(text_number == '输入金额（元）')
      text_number = "0"
      $('#pay-number-box').addClass("active")
    if(text_number.indexOf(".") < 0)
      text_number += $(this).text()
    $('#pay-number-box').text(text_number)
    $('#pay_amount').val(text_number)

  #删除键
  $('#pay-number-keyboard .back').on 'click', (e)->
    text_number = $('#pay-number-box').text()
    if(text_number != '输入金额（元）')
      if(text_number.length > 1)
        text_number = text_number.substring(0,text_number.length-1 )
        $('#pay_amount').val(text_number)
      else
        text_number = '输入金额（元）'
        $('#pay_amount').val(0)
        $('#pay-number-box').removeClass("active")
    $('#pay-number-box').text(text_number)

  $('.req-bill-btn').on 'click', (e)->
    e.preventDefault()
    return false if requesting_bill
    pay_amount = Number($('#pay_amount').val())
    if not pay_amount > 0
      alert('请输入付款金额')
      return false
    if requested_data_cache["bill-#{pay_amount}"] != undefined
      invokePayment(requested_data_cache["bill-#{pay_amount}"])
      return false
    requestBill(ssid, pay_amount)

  #关闭键盘
  $(document).on 'click', (e) ->
    return true if $(e.target).parent('#pay-number-box').length > 0 || $(e.target).attr('id') == 'pay-number-box'
    if $(e.target).parents('#pay-number-keyboard').length == 0
      $('#pay-number-keyboard').addClass('hidden')
      $('#pay-number-box').addClass("nofoucs")

  $(document).on 'click', '.bill-draw-btn', (e) ->
    e.preventDefault()
    element = $(this)
    if element.hasClass('login-require')
      mobile  = $('#new_mobile').val()
      captcha = $('#mobile_auth_code').val()
      unless !!mobile
        alert('请输入手机号')
        return false
      unless !!captcha
        alert('请输入验证码')
        return false
      UBoss.chopper.showSpinner()
      $.ajax
        url: '/sign_in.json'
        type: 'POST'
        data:
          user:
            login: mobile
            mobile_auth_code: captcha
      .done (data)->
        console.log(data)
        $('form [name=' + data["csrf_param"] + ']').val(data["csrf_token"])
        $('meta[name=csrf-token]').attr('content', data['csrf_token'])
        element.removeClass('login-require')
        requestDraw element.attr('href'), (data)->
          element.hide()
          $('.get-p-card-btn').removeClass('hidden')
      .fail (xhr, errorType, error)->
        alert(
          try
            JSON.parse(xhr.responseText).error
          catch error
            '手机登录失败'
        )
      .always ->
        UBoss.chopper.hideSpinner()
    else
      requestDraw element.attr('href'), (data)->
        $('.bill-draw-cont').remove()
        $('.bill-sharing-cont').removeClass('hidden')

  requestDraw = (url, callback)->
    UBoss.chopper.showSpinner()
    $.ajax
      url: url
      type: 'GET'
    .done (data) ->
      console.log data
      $('.login-cont').remove()
      $('.prize-cont').removeClass('hidden')
      $('.draw-result-cont').text(data.msg)
      callback(data) if callback?
    .fail (xhr, errorType, error) ->
      alert(
        try
          JSON.parse(xhr.responseText).error
        catch error
          '手机登录失败'
      )
    .always ->
      UBoss.chopper.hideSpinner()

  UBoss.luffy.bindPCardTaker '.bill-sharing-cont .get-p-card-btn',
    beforeSendFuc: ->
      if $(this).hasClass('done')
        UBoss.luffy.showWxPopTip()
    successFuc: (data)->
      UBoss.luffy.showWxPopTip()
    failFuc: ->
      console.log 'fail'
    alwaysFuc: ->
      console.log 'alwaysFuc'

  FastClick.attach(document.body)
