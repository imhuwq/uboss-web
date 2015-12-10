#= require zepto/zepto.min
#= require zepto/plugins/fx
#= require zepto/plugins/fx_methods
#= require zepto/plugins/callbacks
#= require zepto/plugins/deferred
#= require rails-behaviors/index
#= require fastclick
#= require mobile_page/going_merry
#= reuqire_self

$ ->
  $('.share-btn').on 'click',(e) ->
    e.preventDefault()
    $('.page1').addClass('hidden')
    $('.page2').removeClass('hidden')

  $('.has-revived-btn').on 'click',(e)->
    e.preventDefault()
    $('.pop-container.nobg').removeClass('hidden')

  $('.pop-container.nobg').on 'click',(e)->
    e.preventDefault()
    $(this).addClass('hidden')

  requesting = false
  $('.receive-bonus-btn').on 'click', (e) ->
    e.preventDefault()
    mobile = $('#u_mobile').val()
    checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    if not checkNum.test(mobile)
      console.log mobile
      alert "手机格式错误"
      return false

    inviter_uid = $('#inviter_uid').val()
    $('#user-tel').text(mobile)
    if requesting
      return false

    requesting = true
    $.ajax
      url: '/bonus/invited',
      type: 'POST',
      data: {
        mobile: mobile
        inviter_uid: inviter_uid
      }
    .done (data)->
      wxSharingOpts.link = data.invite_url
      UBoss.luffy.resetInvokeSharing(wxSharingOpts)
      $('.pop-container').removeClass('hidden')
      requesting = false
    .fail (xhr, textStatus) ->
      requesting = false
      errorInfo = (
        try
          JSON.parse(xhr.responseText)
        catch error
          '领取失败'
      )
      if errorInfo.message == 'received'
        wxSharingOpts.link = errorInfo.invite_url
        UBoss.luffy.resetInvokeSharing(wxSharingOpts)
        $('.received-page').removeClass('hidden')
        $('.receiving-page').addClass('hidden')
      else
        alert(message)
