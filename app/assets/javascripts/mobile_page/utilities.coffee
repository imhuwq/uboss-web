$ ->

  $(document).on 'click', '.share-wx-btn', (e) ->
    e.preventDefault()
    if window.wx != undefined
      $(".wx-mod-pop").show()
    else
      alert('朋友圈分享只在微信浏览器可用')

  $(".wx-mod-pop").on 'click', ->
    $(this).hide()

  flash = $(".auto_close_flash_css")
  setTimeout ->
    flash.fadeOut ->
      $(this).remove()
  , 5000

  $(document).on 'click', '.flash_css', ->
    $(this).remove()

  disabledLoadMore = (e)->
    e.remove()

  $(document).on 'click', '.load-more', (e) ->
    e.preventDefault()
    element = $(this)
    if not element.hasClass('loading')
      if $(element.data('ele')).length > 6 # nothing but set it anyway
        element.addClass('loading')
        element.text('加载中...')
        params = { before_published_at: $(element.data('ele')).last().attr('timestamp') }
        $.get element.data('ref'), params, (data) ->
          if $.trim(data).length
            $(element.data('container')).append(data)
            element.removeClass('loading')
            element.text('加载更多')
          else
            disabledLoadMore(element)
      else
        disabledLoadMore(element)

  $('#load-more').waypoint(waypointHandler, offset: '100%')



  $('#show_inventory').on 'click', ->
    $('#inventory').removeClass('hidden');
    $('.fixed-container').css('-webkit-filter', 'blur(3px)');

  $('.sku').on 'click', ->
    console.log($(this).attr('id'));
    product_inventory_id = $(this).attr('id')
    $('#product_inventory_id').val(product_inventory_id);
    $('.item_click').removeClass('item_click')
    $(this).addClass('item_click')
    $('#price_range').addClass('hidden')
    $('.real_price').addClass('hidden')
    $("#price_#{product_inventory_id}").removeClass('hidden')


  $('#make_order').on 'click', ->
    product_inventory_id = $('#product_inventory_id').val();
    if product_inventory_id == ''
      confirm "请选择你要购买的型号。"
    else
      want_buy = confirm "确认购买么？"
      if want_buy
          $('.product_inventory').submit()
