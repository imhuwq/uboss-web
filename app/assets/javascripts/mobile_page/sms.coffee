$ ->
  mobile_submit_time = 0
  $('#send_mobile').on 'click', (e) ->
    e.preventDefault()
    sendBtn = $(this)
    mobile = $('#new_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    sendBtn.addClass("disabled")
    if checkNum.test(mobile)
      mobile_submit_time = 60
      return false if mobile_submit_time != 0
      sendBtn.addClass("disabled")
      $.ajax
        url: '/mobile_captchas/create',
        type: 'POST',
        data: {mobile: mobile},
      .done ->
        timedown $('#send_mobile')
      .fail ->
        mobile_submit_time = 0
        alert('验证码发送失败')
        sendBtn.removeClass("disabled")
    else
      alert "手机格式错误"

  $('#request_mobile_captcha').on 'click', (e) ->
    e.preventDefault()
    sendBtn = $(this)
    mobile = $('#new_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    if not checkNum.test(mobile)
      console.log mobile
      alert "手机格式错误"
      return false

    captcha = $('input[name=captcha]').val()
    if captcha.length < 1
      alert "请输入图片验证码"
      return false

    return false if mobile_submit_time != 0
    captcha_key = $('input[name=captcha_key]').val()
    sendBtn.addClass("disabled")
    $.ajax
      url: '/mobile_captcha/send_with_captcha',
      type: 'GET',
      data: {
        mobile: mobile
        captcha: captcha
        captcha_key: captcha_key
      },
    .done ->
      $('#refresh_img_captcha_btn').click()
      mobile_submit_time = 60
      timedown sendBtn
    .fail (xhr, textStatus) ->
      sendBtn.removeClass("disabled")
      alert JSON.parse(xhr.responseText).message

  timedown = (t) ->
    if mobile_submit_time == 0
      t.removeClass("disabled")
      t.text("发送验证码")
    else
      t.text("#{mobile_submit_time}s后重新获取")
      mobile_submit_time--
      setTimeout () ->
        timedown(t)
      , 1000

  $('#mobile_auth_code').on 'keyup', (m)->
    code = $(this).val()
    if code.length == 5
      $('#submit_bottom').removeAttr('disabled')
    else
      $('#submit_bottom').attr('disabled','disabled')

  $('#timedown').on 'click', (e) ->
    e.preventDefault()
    sendBtn = $(this)
    mobile = $('#new_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    mobile_submit_time = 60
    if not checkNum.test(mobile)
      console.log mobile
      alert "手机格式错误"
      return false
    return false if mobile_submit_time != 0
    sendBtn.addClass("disabled")
    $.ajax
      url: '/account/send_message',
      type: 'POST',
      data: {
        mobile: mobile
      },
    .done ->
      timedown sendBtn
    .fail (xhr, textStatus) ->
      mobile_submit_time = 0
      sendBtn.removeClass("disabled")
      alert JSON.parse(xhr.responseText).message
