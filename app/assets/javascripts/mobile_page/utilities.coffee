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
      if $(element.data('ele')).length > 4 # nothing but set it anyway
        element.addClass('loading')
        element.text('加载中...')
        reg = new RegExp("(^|&)order=([^&]*)(&|$)")
        r = window.location.search.substr(1).match(reg)
        if (r != null)
          order = unescape(r[2])
        else
          order = ''
        params = { orderdata: $(element.data('ele')).last().attr('orderdata'), order: order }
        $.get element.data('ref'), params, (data) ->
          if $.trim(data).length
            # $(element.data('container')).append(data)
            $('.container').last().append(data)
            element.removeClass('loading')
            element.text('加载更多')
          else
            disabledLoadMore(element)
      else
        disabledLoadMore(element)

  # 浮点数运算 加
  self.floatAdd = (arg1, arg2) ->
    (parseInt(arg1 * 100) + parseInt(arg2 * 100)) / 100

  # 减
  self.floatSub = (arg1, arg2) ->
    (parseInt(arg1 * 100) - parseInt(arg2 * 100)) / 100

  # 乘
  self.floatMul = (arg1, arg2) ->
    parseInt(arg1 * 100) * parseInt(arg2 * 100) / 10000

  # 除
  self.floatDiv = (arg1, arg2) ->
    parseInt(arg1 * 100) / parseInt(arg2 * 100)
