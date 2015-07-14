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

  $('#new_order_form .jia').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    $('#amount').val(amount + 1)
    calulateTotalPrice(amount + 1)

  $('#new_order_form .jian').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    if amount > 1
      $('#amount').val(amount - 1)
      calulateTotalPrice(amount - 1)

  $('.subOrd_box2 #amount').on 'keyup', (event) ->
    amount = $(this).val()
    calulateTotalPrice(amount)

  calulateTotalPrice = (amount) ->
    price = Number($('#order_form_real_price').val())
    $('#total_price').html(amount * price + Number($('#order_form_product_traffic_expense').val()))

  $('.order-address-dlg .add_line1').on 'click', ()->
    $('#order_form_user_address_id').val($(this).data('id'))
    fillNewOrderAddressInfo(
      $(this).find('.adr-user').text(),
      $(this).find('.adr-mobile').text(),
      $(this).find('.adr-detail').text()
    )
    hideOrderAddressDlg()

  $('.order-address-dlg .use-new-addr-btn').on 'click', (event)->
    event.preventDefault()
    user = $('#order_form_deliver_username').val()
    mobile = $('#order_form_deliver_mobile').val()
    street = $('#order_form_street').val()
    building = $('#order_form_building').val()
    if !!user and !!mobile and !!street and !!building
      if UBoss.chopper.valifyMobile(mobile)
        detail = "#{street}#{building}"
        fillNewOrderAddressInfo(user, mobile, detail)
        $('#order_form_user_address_id').val('')
        hideOrderAddressDlg()
      else
        alert('手机号无效')
    else
      alert('请填写完整收货信息')

  hideOrderAddressDlg = ->
    dlg = $('#dlg')
    console.log dlg.attr("status")
    if dlg.attr("status") == '1'
      dlg.attr("status", "0")
      dlg.hide()
      $('#new_order_form #content').removeClass('active')

  fillNewOrderAddressInfo = (user, mobile, detail)->
    $('.new-order-addr-info .adr-user').text(user)
    $('.new-order-addr-info .adr-mobile').text(mobile)
    $('.new-order-addr-info .adr-detail').text(detail)
    $('.new-order-addr-info').show()
