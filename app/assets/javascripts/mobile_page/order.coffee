$ ->

  sharing_lv1_amount = Number($('.sharing_lv1_amount').text())
  privilege_amount = Number($('#pay_text').val())
  present_price = Number($('#privilege_card_present_price').val())
  origin_privilege_amount = Number($('#origin_privilege_amount').val())
  origin_sharing_amount = Number($('#origin_sharing_amount').val())
  maxPrivilegeAmount = origin_sharing_amount + origin_privilege_amount
  set_privilege_card_info = ->
    discount = (present_price - privilege_amount) * 10 / present_price
    $('.pay_line1 > strong').text(discount.toFixed(2))
    $('.sharing_lv1_amount').text(sharing_lv1_amount)
    $('#pay_text').val(privilege_amount)

  $('#pay_text').on 'blur', (e)->
    if this.value > maxPrivilegeAmount
      alert "亲，最高优惠#{maxPrivilegeAmount}"
      privilege_amount = maxPrivilegeAmount
      sharing_lv1_amount = 0
    else if this.value < privilege_amount
      alert '亲，给朋友留点折扣吧'
      privilege_amount = origin_privilege_amount
      sharing_lv1_amount = origin_sharing_amount
    else
      privilege_amount = this.value
      sharing_lv1_amount = maxPrivilegeAmount - privilege_amount
    set_privilege_card_info()

  $('.edit_privilege_card .jia').on 'tap', (e)->
    e.preventDefault()
    if sharing_lv1_amount >= 1
      sharing_lv1_amount -= 1
      privilege_amount += 1
      set_privilege_card_info()

  $('.edit_privilege_card .jian').on 'tap', (e)->
    e.preventDefault()
    if privilege_amount >= origin_privilege_amount + 1
      sharing_lv1_amount += 1
      privilege_amount -= 1
      set_privilege_card_info()
    else
      alert '亲，给朋友留点折扣吧'

  $('.edit_privilege_card').on 'ajaxSuccess', (e, data)->
    if data.actived
      want_sharing = confirm 'BOSS，您的友情卡已激活，收货后分享给朋友打折吧！'
      if want_sharing
        window.location = $('.pay-complete-actions a').attr('href')
      else
        $('.pay-complete-actions').addClass('sharing-active')
    else
      alert '恭喜您获得本商品的友情卡，收货后激活可以给朋友打折哦！'
      window.location = $('.pay-complete-actions a').attr('href')

  $('.edit_privilege_card').on 'ajaxError', (event, xhr, status, error) ->
    alert xhr.responseText

  $('#new_order_form .jia').on 'tap', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    $('#amount').val(amount + 1)
    calulateTotalPrice(amount + 1)

  $('#new_order_form .jian').on 'tap', (e)->
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

  $('.order-address-dlg .add_line1').on 'tap', ()->
    $('#order_form_user_address_id').val($(this).data('id'))
    fillNewOrderAddressInfo(
      $(this).find('.adr-user').text(),
      $(this).find('.adr-mobile').text(),
      $(this).find('.adr-detail').text()
    )
    hideOrderAddressDlg()

  $('.order-address-dlg .use-new-addr-btn').on 'tap', (event)->
    event.preventDefault()
    user = $('#order_form_deliver_username').val()
    mobile = $('#order_form_deliver_mobile').val()
    street = $('#order_form_street').val()
    building = $('#order_form_building').val()
    if !!user and !!mobile and !!street and !!building
      if UBOSS.chopper.valifyMobile(mobile)
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
