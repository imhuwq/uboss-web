$ ->

  tmpPwd = ''
  tmpCap = ''
  bindLoginListener = (event)->
    $('.login-type-acs .lpwd-btn').on event, (e) ->
      e.preventDefault()
      $(this).closest('.login-container').removeClass('using-cap').addClass('using-pwd')
      tmpCap = $('#user_mobile_auth_code').val()
      $('#user_mobile_auth_code').val('')
      $('#user_password').val(tmpPwd)

    $('.login-type-acs .lcap-btn').on event, (e) ->
      e.preventDefault()
      $(this).closest('.login-container').removeClass('using-pwd').addClass('using-cap')
      tmpPwd = $('#user_password').val()
      $('#user_password').val('')
      $('#user_mobile_auth_code').val(tmpCap)

  if typeof(Zepto) != 'undefined'
    bindLoginListener('tap')
  else
    bindLoginListener('click')
