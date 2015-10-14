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

  $('.edit_privilege_card .jia').on 'click', (e)->
    e.preventDefault()
    if sharing_lv1_amount >= 1
      sharing_lv1_amount -= 1
      privilege_amount += 1
      set_privilege_card_info()

  $('.edit_privilege_card .jian').on 'click', (e)->
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

  $('#new_order_form .jia').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    $('#amount').val(amount + 1)
    calulateTotalPrice()

  $('#new_order_form .jian').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    if amount > 1
      $('#amount').val(amount - 1)
      calulateTotalPrice()

  $('.subOrd_box2 #amount').on 'keyup', (event) ->
    calulateTotalPrice()

  $('#address-list-box .add_line1').on 'click', ()->
    $('#order_form_user_address_id').val($(this).data('id'))
    fillNewOrderAddressInfo(
      $(this).find('.adr-user').text(),
      $(this).find('.adr-mobile').text(),
      $(this).find('.adr-detail').text()
    )
    hideOrderAddressDlg()
    changeShipPrice()

  $('#address-new .use-new-addr-btn').on 'click', (event)->
    event.preventDefault()
    user = $('#order_form_deliver_username').val()
    mobile = $('#order_form_deliver_mobile').val()
    province_val = $('.city-select#province').val()
    province_str = ".city-select#province option[value$=\"#{province_val}\"]"
    province = $(province_str).text()
    city_val = $('.city-select#city').val()
    city_str = ".city-select#city option[value$=\"#{city_val}\"]"
    city = $(city_str).text()
    area_val = $('.city-select#area').val()
    area_str = ".city-select#area option[value$=\"#{area_val}\"]"
    area = $(area_str).text()
    building = $('#order_form_building').val()
    if !!user and !!mobile and !!province and !!city and !! area and !!building
      if UBoss.chopper.valifyMobile(mobile)
        detail = "#{province}#{city}#{area}#{building}"
        fillNewOrderAddressInfo(user, mobile, detail)
        $('#order_form_user_address_id').val('')
        hideOrderAddressDlg()
        changeShipPrice()
        $(".accunt_adilbtn").removeAttr('disabled')
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

  # 修改运费
  changeShipPrice = ->
    cart_id = $('#order_form_cart_id').val()
    product_id = $('#order_form_product_id').val()
    product_inventory_id = $('#order_form_product_inventory_id').val()
    count = $('#order_form_amount').val()
    user_address_id = $('#order_form_user_address_id').val()
    province = $('#province').val()
    $.ajax
      url: '/orders/ship_price'
      type: 'POST'
      data: {
        cart_id: cart_id,
        product_id: product_id,
        product_inventory_id: product_inventory_id,
        count: count,
        user_address_id: user_address_id,
        province: province
      }
      success: (res) ->
        alert('修改收货地址后请重新确认订单信息')
        if res['status'] == "ok"
          if res['is_cart'] == 1     # 购物车入口
            $.each(res['ship_price'] , () ->
              $('.ship_price_'+this[0]).html('<strong></strong>￥ '+this[1])
              $('.ship_price_'+this[0]).data("ship-price"+this[1])
              calulateTotalPriceWithSeller(this[0], this[1])
            )
            calulateCartTotalPrice(res['ship_price'])
          else                       # 直接购买入口
            $('.ship_price_'+res['seller_id']).html('<strong></strong>￥ '+res['ship_price'])
            $('.ship_price_'+res['seller_id']).data("ship-price"+ res['ship_price'])
            calulateTotalPrice()
        else
      error: (data, status, e) ->
        alert('收货地址修改失败')
        location.reload()

  calulateTotalPrice = () ->
    amount = parseInt($('#amount').val())
    price = Number($('#order_form_real_price').val())
    $('#total_price').html(amount * price + Number($('#order_form_product_traffic_expense').val()))

  calulateTotalPriceWithSeller = (seller_id, ship_price) ->
    total_price = Number($('.total_price_'+seller_id).data('total-price'))
    $('.total_price_'+seller_id).text(total_price+Number(ship_price))

  calulateCartTotalPrice = (ship_price) ->
    total_price = 0.0
    for price, i in ship_price
      total_price += Number($('.total_price_'+price[0]).data('total-price'))
      total_price += Number(price[1])
    $('#total_price').text(total_price)
