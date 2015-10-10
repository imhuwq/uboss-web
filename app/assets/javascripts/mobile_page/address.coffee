$ ->
  $('#address').on 'click', ->
    $('#address-list-box').removeClass('hidden')
    $('html,body').addClass('lock')
    
  $('#address-list-box .close').on 'click',->
    $('#address-list-box').addClass('hidden')
    $('html,body').removeClass('lock')
    
  $('#address-more').on 'click', ->
    $('#address-new').removeClass('hidden')
    
  $('#address-new .close').on 'click',->
    $('#address-new').addClass('hidden')
  
  $('#address-new .btn').on 'click', (event)->
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
        $('#address-list-box').addClass('hidden')
        $('html,body').removeClass('lock')
        $('#address-new').addClass('hidden')
      else
        alert('手机号无效')
    else
      alert('请填写完整收货信息')
  
  fillNewOrderAddressInfo = (user, mobile, detail)->
    $('#address .address-box .adr-user').text(user)
    $('#address .address-box .adr-mobile').text(mobile)
    $('#address .address-box .adr-detail').text(detail)
    $('#address .address-box').removeClass('hidden')
    $('.none-address-box').hide()