# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->

  mobile_submit_time = 0
  $('#send_mobile').on 'click', (e) ->
    e.preventDefault()
    sendBtn = $(this)
    mobile = $('#new_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    if checkNum.test(mobile)
      console.log mobile_submit_time
      return false if mobile_submit_time != 0
      mobile_submit_time = 60
      sendBtn.addClass("disabled")
      data = if sendBtn.data 'invite-agency' then {mobile: mobile, captcha_type: 'invite_agency'} else {mobile: mobile}
      $.ajax
        url: '/mobile_captchas/create',
        type: 'POST',
        data: data
      .done ->
        if sendBtn.data 'invite-agency'
          $('.invite-agency-success .modal-content span').text(mobile)
          $('.invite-agency-success').modal()
        else
          timedown $('#send_mobile')
      .fail ->
        mobile_submit_time = 0
        sendBtn.removeClass("disabled")
        alert('发送失败')
    else
      console.log mobile
      alert "手机格式错误"

  timedown = (t) ->
    if mobile_submit_time == 0
      t.removeClass("disabled")
      t.text("发送手机验证码")
    else
      t.addClass("disabled")
      t.text("#{mobile_submit_time} 秒后再次获取")
      mobile_submit_time--
      setTimeout () ->
        timedown(t)
      , 1000

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
    mobile_submit_time = 60
    sendBtn.addClass("disabled")
    $.ajax
      url: '/mobile_captchas/send_with_captcha',
      type: 'GET',
      data: {
        mobile: mobile
        captcha: captcha
        captcha_key: captcha_key
      },
    .done ->
      $('#refresh_img_captcha_btn').click()
      timedown sendBtn
    .fail (xhr, textStatus) ->
      mobile_submit_time = 0
      sendBtn.removeClass("disabled")
      if xhr.responseJSON?
        alert(xhr.responseJSON.message)
      else
        alert('发送失败')

  $('#authorize_agency').on 'click', ->
    mobile_auth_code = $('#mobile_auth_code').val()
    checkNum = /^[0-9]{5}$/
    if not checkNum.test(mobile_auth_code)
      alert "验证码格式错误"
      return false
    else
      $.ajax
        url: '/admin/build_cooperation',
        type: 'POST',
        data: {
          mobile_auth_code: mobile_auth_code
        },
      .done ->
        alert '您已成功授权'
      .fail (xhr, textStatus) ->
        if xhr.responseJSON?
          alert(xhr.responseJSON.message)
        else
          alert '授权失败'
