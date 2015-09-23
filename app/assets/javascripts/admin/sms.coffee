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
      $.ajax
        url: '/mobile_captchas/create',
        type: 'POST',
        data: {mobile: mobile},
      .done ->
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

  $('#mobile_auth_code').on 'keyup', (m)->
    code = $(this).val()
    if code.length == 5
      $('#submit_bottom').removeAttr('disabled')
    else
      $('#submit_bottom').attr('disabled','disabled')

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
