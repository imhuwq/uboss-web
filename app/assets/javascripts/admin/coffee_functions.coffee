# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->

  mobile_submit_time = 0
  $('#send_mobile').on 'click', (e) ->
    e.preventDefault()
    mobile = $('#new_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    if checkNum.test(mobile)
      console.log mobile_submit_time
      return false if mobile_submit_time != 0
      $.ajax
        url: '/mobile_auth_code/create',
        type: 'POST',
        data: {mobile: mobile},
      .always ->
        console.log("complete")
        console.log(mobile_submit_time)
        mobile_submit_time = 60
        timedown $('#send_mobile')
    else
      console.log mobile
      alert "手机格式错误"

  timedown = (t) ->
    if mobile_submit_time == 0
      t.removeClass("disabled")
      t.text("发送验证码")
    else
      t.addClass("disabled")
      t.text("#{mobile_submit_time} 秒后再次获取")
      mobile_submit_time--
      setTimeout () ->
        timedown(t)
      , 1000
