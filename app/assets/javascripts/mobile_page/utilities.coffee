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
