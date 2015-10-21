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

  $(document).on 'click', '.alert', ->
    $(this).closest('.flash_css').remove()

  disabledLoadMore = (e)->
    e.removeClass('loading')
    e.addClass('done')
    e.text('已无更多')
    e.remove()

  waypointHandler = (direction) ->
    element = $(this.element)
    if not element.hasClass('loading') and direction == 'down'
      Waypoint.destroyAll()
      if $(element.data('ele')).length > 6 # nothing but set it anyway
        element.addClass('loading')
        element.text('加载中...')
        params = { before_published_at: $(element.data('ele')).last().attr('timestamp') }
        $.get element.data('ref'), params, (data) ->
          if $.trim(data).length
            $(element.data('container')).append(data)
            element.removeClass('loading')
            element.text('加载更多')
            # $('#load-more').waypoint(waypointHandler, offset: '100%')
          else
            disabledLoadMore(element)
      else
        disabledLoadMore(element)

  # $('#load-more').waypoint(waypointHandler, offset: '100%')



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


  # $('#make_order').on 'click', ->
  #   product_inventory_id = $('#product_inventory_id').val();
  #   if product_inventory_id == ''
  #     confirm "请选择你要购买的型号。"
  #   else
  #     want_buy = confirm "确认购买么？"
  #     if want_buy
  #         $('.product_inventory').submit()
