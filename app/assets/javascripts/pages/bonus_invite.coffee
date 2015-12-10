#= require zepto/zepto.min
#= require zepto/plugins/fx
#= require zepto/plugins/fx_methods
#= require zepto/plugins/callbacks
#= require zepto/plugins/deferred
#= require rails-behaviors/index
#= require fastclick
#= reuqire_self

$ ->

  $('.receive-bonus-btn').on 'click', (e) ->
    e.preventDefault()
    mobile = $('#u_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    if not checkNum.test(mobile)
      console.log mobile
      alert "手机格式错误"
      return false

    inviter_uid = $('#inviter_uid').val()
    $.ajax
      url: '/bonus/invited',
      type: 'POST',
      data: {
        mobile: mobile
        inviter_uid: inviter_uid
      }
    .done (data)->
      alert "success: #{data.amount}"
    .fail (xhr, textStatus) ->
      message = (
        try
          JSON.parse(xhr.responseText).message
        catch error
          '领取失败'
      )
      if message == 'received'
        alert('已领取')
      else
        alert(message)
