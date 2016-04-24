#= require zepto/zepto.min
#= require zepto/plugins/fx
#= require zepto/plugins/fx_methods
#= require zepto/plugins/callbacks
#= require zepto/plugins/deferred
#= require rails-behaviors/index
#= require fastclick
#= require swipe
#= require querystring
#= require mobile_page/upyun/zepto-iframe-fileupload
#= require mobile_page/upyun/upload
#= require mobile_page/sms
#= require mobile_page/going_merry
#= require mobile_page/utilities
#= require mobile_page/sharing
#= require mobile_page/product
#= require mobile_page/cart
#= require mobile_page/order
#= require mobile_page/pay
#= require mobile_page/evaluations
#= require mobile_page/service_store
#= require mobile_page/recommend
#= require mobile_page/bill_orders
#= require mobile_page/calling_service
#= require shared/count_down
#= require shared/city_select
#= require shared/login
#= reuqire_self

$ ->

  FastClick.attach document.body

  $('form').on 'keyup keypress', (e) ->
    code = e.keyCode || e.which
    if (code == 13)
      e.preventDefault()
      return false

  new Swipe document.getElementById('slider'),
    speed: 300
    auto: 5000
    continuous: true
    disableScroll: false
    stopPropagation: true
    transitionEnd: (index, elem) ->
      $('#slider-points span').removeClass('active')
      $('#slider-points span').eq(index).addClass('active')

  new Swipe document.getElementById('ad-slider'),
    speed: 300
    auto: 5000
    continuous: true
    disableScroll: false
    stopPropagation: true

  $("header .menu-btn").on 'click', ->
    $('header .nav-bar').toggle()

  $(".store-tel").on 'click', ->
    $('.phone-list').toggle()

  $('.container').on 'click', ->
    $('header .nav-bar').hide();

  $(document).on 'click', '.pop-bg', (e) ->
    unless $(e.target).closest('.pop-content').length > 0
      $(this).hide()

  $(document).on 'click', '.lottery-modal', (e) ->
    unless $(e.target).closest('.pop-content').length > 0
      $('#lottery-icon').removeClass('hidden')

  $('.tab-nav .tab').on 'click', (e)->
    $('.tab-nav .tab').removeClass('active')
    $(this).addClass('active')
    tid=$(this).attr('title')
    $('.tab-container .tab-content').hide()
    $(tid).show()

  $('.alert-error .close').on 'click', (e)->
    $(this).closest('.alert-error').remove()

  $('.chat-to-btn').each ->
    element = $(this)
    $.getJSON "/chat/check_user_online",
      user_id: $(this).data('uid')
    , (response) ->
      element.addClass("online") if response.online

  $('.category-more-btn').on 'click',->
    $('.category-more-box').toggleClass('hidden')
    $(this).toggleClass('up')

  $('.recommend-icon span').on 'click',(e)->
    e.preventDefault()
    me = $(this)
    id  = me.parent().closest('.order-item-box').data('id')
    $.ajax
      url: "/products/#{id}/recommend"
      type: 'GET'
      success: (res) ->
        if res['status'] == "ok"
          me.toggleClass('active')
        else
          alert(res['error'])

  $('#ucategory-more').on 'click' , ->
    if $(this).hasClass('arrow-top')
      $(this).removeClass('arrow-top')
      $('.ucategory-list').attr('style','max-height:209px')
    else
      $(this).addClass('arrow-top')
      $('.ucategory-list').attr('style','')

